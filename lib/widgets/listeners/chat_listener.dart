part of 'package:maid/main.dart';

class ChatListener extends StatelessWidget{
  final Widget Function(BuildContext context, Widget? child) builder;

  const ChatListener({
    super.key,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: ChatController.instance,
    builder: builder,
  );

  Widget buildMessageListener(int index) => ListenableBuilder(
    listenable: ChatController.instance.root.chain[index],
    builder: ChatController.instance.root.chain.length - 1 >= index 
      ? (context, child) => builder(context, child)
      : (context, child) => buildMessageListener(index + 1),
  );
}