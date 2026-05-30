class Message {
  final int id;
  final String content;
  final String messageType;
  final String? sentAt;
  final int senderId;
  final String senderName;
  final int? receiverId;
  final int? projectId;

  Message({
    required this.id,
    required this.content,
    required this.messageType,
    this.sentAt,
    required this.senderId,
    required this.senderName,
    this.receiverId,
    this.projectId,
  });

  factory Message.fromJson(Map<String, dynamic> json) => Message(
        id: json['id'],
        content: json['content'],
        messageType: json['messageType'] ?? 'DIRECT',
        sentAt: json['sentAt'],
        senderId: json['senderId'],
        senderName: json['senderName'] ?? '',
        receiverId: json['receiverId'],
        projectId: json['projectId'],
      );

  Map<String, dynamic> toJson() => {
        'content': content,
        'messageType': messageType,
        if (receiverId != null) 'receiverId': receiverId,
        if (projectId != null) 'projectId': projectId,
      };
}
