// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ServiceProviderDto.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ServiceProviderDtoAdapter extends TypeAdapter<ServiceProviderDto> {
  @override
  final int typeId = 1;

  @override
  ServiceProviderDto read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ServiceProviderDto(
      id: fields[0] as int,
      isAvailable: fields[1] as bool,
      bio: fields[2] as String,
      providerType: fields[3] as String,
      specialization: fields[4] as String,
      pay: fields[5] as double,
      business: fields[6] as String,
      owner: fields[7] as String,
      workerTypes: fields[8] as int,
    );
  }

  @override
  void write(BinaryWriter writer, ServiceProviderDto obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.isAvailable)
      ..writeByte(2)
      ..write(obj.bio)
      ..writeByte(3)
      ..write(obj.providerType)
      ..writeByte(4)
      ..write(obj.specialization)
      ..writeByte(5)
      ..write(obj.pay)
      ..writeByte(6)
      ..write(obj.business)
      ..writeByte(7)
      ..write(obj.owner)
      ..writeByte(8)
      ..write(obj.workerTypes);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ServiceProviderDtoAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
