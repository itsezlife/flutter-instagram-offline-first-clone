// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';

import 'package:app_ui/app_ui.dart';
import 'package:chats_repository/chats_repository.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_instagram_offline_first_clone/app/app.dart';
import 'package:flutter_instagram_offline_first_clone/chats/chat/chat.dart';
import 'package:flutter_instagram_offline_first_clone/l10n/l10n.dart';
import 'package:flutter_instagram_offline_first_clone/stories/stories.dart';
import 'package:inview_notifier_list/inview_notifier_list.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:shared/shared.dart';
import 'package:user_repository/user_repository.dart';

class ChatPage extends StatelessWidget {
  const ChatPage({required this.chatId, required this.chat, super.key});

  final ChatInbox chat;
  final String chatId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ChatBloc(
        chatId: chatId,
        chatsRepository: context.read<ChatsRepository>(),
      )..add(const ChatMessagesFetchRequested()),
      child: ChatView(chat: chat),
    );
  }
}

class ChatView extends StatefulWidget {
  const ChatView({required this.chat, super.key});

  final ChatInbox chat;

  @override
  State<ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> {
  late MessageInputController _messageInputController;
  late FocusNode _focusNode;

  late ItemScrollController _itemScrollController;
  late ItemPositionsListener _itemPositionsListener;
  late ScrollOffsetController _scrollOffsetController;
  late ScrollOffsetListener _scrollOffsetListener;

  Future<void> _reply(Message message) async {
    _messageInputController.setReplyingMessage(message);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  Future<void> _edit(Message message) async {
    _messageInputController.setEditingMessage(message);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  void _delete(Message message) {
    context.read<ChatBloc>().add(ChatMessageDeleteRequested(message.id));
  }

  @override
  void initState() {
    super.initState();
    _messageInputController = MessageInputController();
    _focusNode = FocusNode();

    _itemScrollController = ItemScrollController();
    _itemPositionsListener = ItemPositionsListener.create();
    _scrollOffsetController = ScrollOffsetController();
    _scrollOffsetListener = ScrollOffsetListener.create();
  }

  @override
  void dispose() {
    _messageInputController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = context.read<AppBloc>().state.user;
    bool isMine(Message message) {
      return message.sender?.id == user.id;
    }

    return AppScaffold(
      appBar: ChatAppBar(participant: widget.chat.participant),
      releaseFocus: true,
      body: Column(
        children: [
          Expanded(
            child: BlocBuilder<ChatBloc, ChatState>(
              builder: (context, state) {
                final messages = state.messages;
                return ChatMessagesListView(
                  messages: messages,
                  messageSettings: MessageSettings.create(
                    onReplyTap: (message) => _reply.call(
                      message.copyWith(
                        replyMessageUsername: isMine(message)
                            ? user.username
                            : widget.chat.participant.username,
                      ),
                    ),
                    onEditTap: _edit,
                    onDeleteTap: _delete,
                  ),
                  itemScrollController: _itemScrollController,
                  itemPositionsListener: _itemPositionsListener,
                  scrollOffsetController: _scrollOffsetController,
                  scrollOffsetListener: _scrollOffsetListener,
                );
              },
            ),
          ),
          ChatMessageTextField(
            focusNode: _focusNode,
            itemScrollController: _itemScrollController,
            messageInputController: _messageInputController,
            chat: widget.chat,
          ),
        ],
      ),
    );
  }
}

class ChatMessagesListView extends StatefulWidget {
  const ChatMessagesListView({
    required this.messages,
    required this.itemScrollController,
    required this.itemPositionsListener,
    required this.scrollOffsetController,
    required this.scrollOffsetListener,
    required this.messageSettings,
    super.key,
  });

  final List<Message> messages;
  final MessageSettings messageSettings;
  final ItemScrollController itemScrollController;
  final ItemPositionsListener itemPositionsListener;
  final ScrollOffsetController scrollOffsetController;
  final ScrollOffsetListener scrollOffsetListener;

  @override
  State<ChatMessagesListView> createState() => _ChatMessagesListViewState();
}

class _ChatMessagesListViewState extends State<ChatMessagesListView>
    with SingleTickerProviderStateMixin {
  late ValueNotifier<bool> _showScrollToBottom;
  late ValueNotifier<bool> _isNextPageLoading;

  late final Animation<double> _animation = CurvedAnimation(
    curve: Curves.easeOutQuad,
    parent: _controller,
  );
  late final AnimationController _controller = AnimationController(vsync: this);

  MessageSettings get settings => widget.messageSettings;
  List<Message> get messages => widget.messages;

  final _autoScrollController = AutoScrollController();

  final _listMessagesMap = <String, int>{};

  @override
  void initState() {
    super.initState();
    _showScrollToBottom = ValueNotifier(false);
    _isNextPageLoading = ValueNotifier(false);
  }

  @override
  void didUpdateWidget(covariant ChatMessagesListView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!const ListEquality<Message>().equals(
      oldWidget.messages,
      widget.messages,
    )) {
      if (widget.messages.length == oldWidget.messages.length - 1) {
        _listMessagesMap.clear();
      }
      _updateMessages();
    }
  }

  void _updateMessages() {
    for (var i = 0; i < messages.length; i++) {
      _listMessagesMap[messages[i].id] = i;
    }
  }

  Future<void> _scrollToMessage(
    String repliedMessageId,
    List<Message> messages, {
    bool withHighlight = true,
  }) async {
    final index = messages.indexWhere((m) => m.id == repliedMessageId);
    if (index == -1) return;
    await _autoScrollController.scrollToIndex(
      index,
      preferPosition: AutoScrollPosition.middle,
    );
    if (withHighlight) {
      await _autoScrollController.highlight(index, highlightDuration: 1500.ms);
    }
  }

  @override
  void dispose() {
    _showScrollToBottom.dispose();
    _isNextPageLoading.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasMore = context.select((ChatBloc bloc) => bloc.state.hasMore);

    return Stack(
      children: [
        const ChatBackground(),
        Column(
          children: [
            Flexible(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return InViewNotifierCustomScrollView(
                    onListEndReached: () async {
                      if (!hasMore) return;
                      if (_isNextPageLoading.value) return;

                      Future<void> loadNextPage() async => context
                          .read<ChatBloc>()
                          .add(const ChatMessagesFetchRequested());

                      _controller
                        ..duration = Duration.zero
                        // ignore: unawaited_futures
                        ..forward();

                      _isNextPageLoading.value = true;

                      await loadNextPage().whenComplete(() {
                        if (mounted) {
                          _controller
                            ..duration = const Duration(milliseconds: 300)
                            ..reverse();

                          _isNextPageLoading.value = false;
                        }
                      });
                    },
                    physics: const AlwaysScrollableScrollPhysics(),
                    controller: _autoScrollController,
                    initialInViewIds: [messages.lastOrNull?.id ?? ''],
                    isInViewPortCondition: (deltaTop, deltaBottom, vpHeight) {
                      return deltaTop < (0.5 * vpHeight) + 80.0 &&
                          deltaBottom > (0.5 * vpHeight) - 80.0;
                    },
                    reverse: true,
                    slivers: [
                      SliverList.separated(
                        itemCount: messages.length,
                        findChildIndexCallback: (key) {
                          final valueKey = key as ValueKey<String>;
                          final val = _listMessagesMap[valueKey.value];
                          return val;
                        },
                        itemBuilder: (context, index) {
                          final isFirst = index == 0;
                          final isLast = index + 1 == messages.length;
                          final isPreviousLast = index + 1 < messages.length;
                          final message = messages[index];
                          final nextMessage = isLast
                              ? null
                              : messages[index + 1];
                          final previousMessage = isPreviousLast
                              ? null
                              : messages[index - 1];
                          final isNextUserSame =
                              nextMessage != null &&
                              message.sender!.id == nextMessage.sender!.id;
                          final isPreviousUserSame =
                              previousMessage != null &&
                              message.sender!.id == previousMessage.sender!.id;

                          bool checkTimeDifference(
                            DateTime date1,
                            DateTime date2,
                          ) => !Jiffy.parseFromDateTime(date1).isSame(
                            Jiffy.parseFromDateTime(date2),
                            unit: Unit.minute,
                          );

                          var hasTimeDifferenceWithNext = false;
                          if (nextMessage != null) {
                            hasTimeDifferenceWithNext = checkTimeDifference(
                              message.createdAt,
                              nextMessage.createdAt,
                            );
                          }

                          var hasTimeDifferenceWithPrevious = false;
                          if (previousMessage != null) {
                            hasTimeDifferenceWithPrevious = checkTimeDifference(
                              message.createdAt,
                              previousMessage.createdAt,
                            );
                          }

                          final messageWidget = AutoScrollTag(
                            index: index,
                            key: ValueKey('scroll-${message.id}'),
                            controller: _autoScrollController,
                            highlightColor: AppColors.blue.withValues(
                              alpha: .2,
                            ),
                            child: MessageBubble(
                              onEditTap: settings.onEditTap,
                              onReplyTap: settings.onReplyTap,
                              onDeleteTap: settings.onDeleteTap,
                              onRepliedMessageTap: (repliedMessageId) =>
                                  _scrollToMessage(repliedMessageId, messages),
                              message: message,
                              onMessageTap:
                                  (
                                    details,
                                    messageId, {
                                    required isMine,
                                    required hasSharedPost,
                                  }) => settings.onMessageTap(
                                    details,
                                    messageId,
                                    context: context,
                                    isMine: isMine,
                                    hasSharedPost: hasSharedPost,
                                  ),
                              borderRadius: ({required isMine}) =>
                                  BorderRadius.only(
                                    topLeft: isMine
                                        ? const Radius.circular(22)
                                        : (isNextUserSame &&
                                              !hasTimeDifferenceWithNext)
                                        ? const Radius.circular(4)
                                        : const Radius.circular(22),
                                    topRight: !isMine
                                        ? const Radius.circular(22)
                                        : (isNextUserSame &&
                                              !hasTimeDifferenceWithNext)
                                        ? const Radius.circular(4)
                                        : const Radius.circular(22),
                                    bottomLeft: isMine
                                        ? const Radius.circular(22)
                                        : (isPreviousUserSame &&
                                              !hasTimeDifferenceWithPrevious)
                                        ? const Radius.circular(4)
                                        : Radius.zero,
                                    bottomRight: !isMine
                                        ? const Radius.circular(22)
                                        : (isPreviousUserSame &&
                                              !hasTimeDifferenceWithPrevious)
                                        ? const Radius.circular(4)
                                        : Radius.zero,
                                  ),
                            ),
                          );

                          final padding = isFirst
                              ? const EdgeInsets.only(bottom: AppSpacing.md)
                              : isLast
                              ? const EdgeInsets.only(top: AppSpacing.md)
                              : null;

                          return SwipeableMessage(
                            key: ValueKey(message.id),
                            onSwiped: (_) => settings.onReplyTap.call(message),
                            child: Padding(
                              padding: padding ?? EdgeInsets.zero,
                              child: messageWidget,
                            ),
                          );
                        },
                        separatorBuilder: (context, index) {
                          final isLast = messages.length == index + 1;
                          final message = messages[index];
                          final nextMessage = isLast
                              ? null
                              : messages[index + 1];
                          if (message.createdAt.day !=
                              nextMessage?.createdAt.day) {
                            return MessageDateTimeSeparator(
                              date: message.createdAt,
                            );
                          }
                          final isNextUserSame =
                              nextMessage != null &&
                              message.sender?.id == nextMessage.sender?.id;

                          var hasTimeDifference = false;

                          if (nextMessage != null) {
                            hasTimeDifference =
                                !Jiffy.parseFromDateTime(
                                  message.createdAt,
                                ).isSame(
                                  Jiffy.parseFromDateTime(
                                    nextMessage.createdAt,
                                  ),
                                  unit: Unit.minute,
                                );
                          }

                          if (isNextUserSame && !hasTimeDifference) {
                            return const Gap.v(AppSpacing.xxs);
                          }

                          return const Gap.v(AppSpacing.sm);
                        },
                      ),
                      SliverPadding(
                        padding: EdgeInsets.only(
                          top:
                              16 +
                              (context.isMobile
                                  ? MediaQuery.paddingOf(context).top
                                  : 0),
                        ),
                        sliver: SliverToBoxAdapter(
                          child: SizeTransition(
                            axisAlignment: 1,
                            sizeFactor: _animation,
                            child: Center(
                              child: Container(
                                alignment: Alignment.center,
                                height: 38,
                                width: 38,
                                child: const SizedBox(
                                  height: 26,
                                  width: 26,
                                  child: CircularProgressIndicator.adaptive(
                                    strokeWidth: 2,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
        ValueListenableBuilder<bool>(
          valueListenable: _showScrollToBottom,
          child: ScrollToBottomButton(
            scrollToBottom: () {
              widget.itemScrollController.scrollTo(
                index: 0,
                duration: 150.ms,
                curve: Curves.easeIn,
              );
              _showScrollToBottom.value = false;
            },
          ),
          builder: (context, show, child) {
            return Positioned(
              right: 0,
              bottom: 0,
              child: AnimatedScale(
                scale: show ? 1 : 0,
                curve: Curves.bounceInOut,
                duration: 150.ms,
                child: child,
              ),
            );
          },
        ),

        /// Unfortunately, chat floating date separator is not working anymore
        /// because I've swapped `ScrollablePositionList` to
        /// `SliverList.separated` in favor of `findChildIndexCallback` which
        /// is not available with `ScrollablePositionList` and it significantly
        /// boosts performance. However, it doesn't mean that we can't scroll
        /// to a specific message. We can still scroll to a specific message
        /// by using [scroll_to_index] package. It adds `AutoScrollController`
        /// and we can use it to scroll to a specific message and also
        /// has built in feature for highlighting the message.
        // Positioned(
        //   top: 0,
        //   left: 0,
        //   right: 0,
        //   child: ChatFloatingDateSeparator(
        //     reverse: false,
        //     messages: messages,
        //     itemCount: messages.length,
        //     itemPositionsListener: ValueNotifier([]),
        //   ),
        // ),
      ],
    );
  }
}

class ChatBackground extends StatelessWidget {
  const ChatBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: switch (context.isLight) {
        true => Assets.images.chatBackgroundLightOverlay.image(
          fit: BoxFit.cover,
        ),
        false => ShaderMask(
          shaderCallback: (bounds) {
            return const LinearGradient(
              begin: FractionalOffset.topCenter,
              end: FractionalOffset.bottomCenter,
              colors: AppColors.primaryBackgroundGradient,
              stops: [0, .33, .66, .99],
            ).createShader(bounds);
          },
          child: Assets.images.chatBackgroundDarkMask.image(fit: BoxFit.cover),
        ),
      },
    );
  }
}

class ChatAppBar extends StatelessWidget implements PreferredSizeWidget {
  const ChatAppBar({required this.participant, super.key});

  final User participant;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      centerTitle: false,
      leadingWidth: 36,
      title: ListTile(
        contentPadding: EdgeInsets.zero,
        title: Text(participant.displayUsername),
        subtitle: Text(context.l10n.onlineText),
        leading: UserStoriesAvatar(
          resizeHeight: 156,
          author: participant,
          enableInactiveBorder: false,
          withAdaptiveBorder: false,
          radius: 22,
        ),
      ),
      bottom: const PreferredSize(
        preferredSize: Size.fromHeight(AppSpacing.xxs),
        child: AppDivider(),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(60);
}

class ScrollToBottomButton extends StatelessWidget {
  const ScrollToBottomButton({required this.scrollToBottom, super.key});

  final VoidCallback scrollToBottom;

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.small(
      shape: const CircleBorder(),
      onPressed: scrollToBottom,
      backgroundColor: context.customReversedAdaptiveColor(
        light: AppColors.white,
        dark: AppColors.emphasizeDarkGrey,
      ),
      child: const Icon(Icons.arrow_downward_rounded),
    );
  }
}
