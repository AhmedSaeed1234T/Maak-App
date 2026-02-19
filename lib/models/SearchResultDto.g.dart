// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'SearchResultDto.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ServiceProviderAdapter extends TypeAdapter<ServiceProvider> {
  @override
  final int typeId = 4;

  @override
  ServiceProvider read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ServiceProvider(
      name: fields[0] as String,
      skill: fields[1] as String,
      location: fields[2] as String,
      pay: fields[3] as String?,
      owner: fields[4] as String?,
      imageUrl: fields[5] as String?,
      isCompany: fields[6] as bool,
      workerType: fields[7] as int?,
      mobileNumber: fields[8] as String?,
      email: fields[9] as String?,
      locationOfServiceArea: fields[10] as String?,
      typeOfService: fields[11] as String?,
      aboutMe: fields[12] as String?,
      userName: fields[14] as String,
      userId: fields[15] as String?,
      isOccupied: fields[16] as bool,
      marketplace: fields[17] as String?,
      derivedSpec: fields[18] as String?,
      cachedAt: fields[13] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, ServiceProvider obj) {
    writer
      ..writeByte(19)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.skill)
      ..writeByte(2)
      ..write(obj.location)
      ..writeByte(3)
      ..write(obj.pay)
      ..writeByte(4)
      ..write(obj.owner)
      ..writeByte(5)
      ..write(obj.imageUrl)
      ..writeByte(6)
      ..write(obj.isCompany)
      ..writeByte(7)
      ..write(obj.workerType)
      ..writeByte(8)
      ..write(obj.mobileNumber)
      ..writeByte(9)
      ..write(obj.email)
      ..writeByte(10)
      ..write(obj.locationOfServiceArea)
      ..writeByte(11)
      ..write(obj.typeOfService)
      ..writeByte(12)
      ..write(obj.aboutMe)
      ..writeByte(13)
      ..write(obj.cachedAt)
      ..writeByte(14)
      ..write(obj.userName)
      ..writeByte(15)
      ..write(obj.userId)
      ..writeByte(16)
      ..write(obj.isOccupied)
      ..writeByte(17)
      ..write(obj.marketplace)
      ..writeByte(18)
      ..write(obj.derivedSpec);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ServiceProviderAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
