// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'UserProfile.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserProfileAdapter extends TypeAdapter<UserProfile> {
  @override
  final int typeId = 2;

  @override
  UserProfile read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserProfile(
      userName: fields[0] as String,
      firstName: fields[1] as String,
      lastName: fields[2] as String,
      email: fields[3] as String,
      phoneNumber: fields[4] as String,
      imageUrl: fields[5] as String,
      points: fields[6] as int,
      subscription: fields[7] as Subscription?,
      serviceProvider: fields[8] as ServiceProviderDto?,
      governorate: fields[9] as String,
      city: fields[10] as String,
      district: fields[11] as String,
      cachedAt: fields[12] as DateTime,
      subscriptionPoints: fields[13] as int?,
    );
  }

  @override
  void write(BinaryWriter writer, UserProfile obj) {
    writer
      ..writeByte(14)
      ..writeByte(0)
      ..write(obj.userName)
      ..writeByte(1)
      ..write(obj.firstName)
      ..writeByte(2)
      ..write(obj.lastName)
      ..writeByte(3)
      ..write(obj.email)
      ..writeByte(4)
      ..write(obj.phoneNumber)
      ..writeByte(5)
      ..write(obj.imageUrl)
      ..writeByte(6)
      ..write(obj.points)
      ..writeByte(7)
      ..write(obj.subscription)
      ..writeByte(8)
      ..write(obj.serviceProvider)
      ..writeByte(9)
      ..write(obj.governorate)
      ..writeByte(10)
      ..write(obj.city)
      ..writeByte(11)
      ..write(obj.district)
      ..writeByte(12)
      ..write(obj.cachedAt)
      ..writeByte(13)
      ..write(obj.subscriptionPoints);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserProfileAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
