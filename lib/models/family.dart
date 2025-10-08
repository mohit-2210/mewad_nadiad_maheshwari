import 'package:mmsn/models/user.dart';
import 'package:nowa_runtime/nowa_runtime.dart';

@NowaGenerated()
class Family {
  const Family({
    required this.id,
    required this.head,
    required this.members,
    required this.society,
    required this.area,
  });

  factory Family.fromJson(Map<String, dynamic> json) {
    return Family(
      id: json['id'] as String,
      head: User.fromJson(json['head'] as Map<String, dynamic>),
      members: (json['members'] as List)
          .map((member) => User.fromJson(member as Map<String, dynamic>))
          .toList(),
      society: json['society'] as String,
      area: json['area'] as String,
    );
  }

  final String id;

  final User head;

  final List<User> members;

  final String society;

  final String area;

  int get totalMembers {
    return members.length + 1;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'head': head.toJson(),
      'members': members.map((member) => member.toJson()).toList(),
      'society': society,
      'area': area,
    };
  }
}
