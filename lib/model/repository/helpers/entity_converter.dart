import 'package:moodtag/model/database/moodtag_db.dart';
import 'package:moodtag/model/entities/entities.dart';
import 'package:moodtag/model/repository/helpers/dto.dart';

class EntityConverter {
  //
  // Artist
  //
  BaseArtist createBaseArtistFromDataClass(ArtistDataClass dataClass, {Set<Tag>? tags}) {
    if (tags != null) {
      return Artist(id: dataClass.id, name: dataClass.name, orderingName: dataClass.orderingName, tags: tags);
    }
    return BaseArtist(id: dataClass.id, name: dataClass.name, orderingName: dataClass.orderingName);
  }

  List<BaseArtist> createBaseArtistsListFromDataClasses(List<ArtistDataClass> dataClassList) {
    return dataClassList.map(createBaseArtistFromDataClass).toList();
  }

  ArtistDataClass convertBaseArtistToDataClass(BaseArtist artist) {
    return ArtistDataClass(id: artist.id, name: artist.name, orderingName: artist.orderingName);
  }

  Artist createArtistFromDTO(ArtistWithTagsDTO artistDTO) {
    return Artist(
        id: artistDTO.artist.id,
        name: artistDTO.artist.name,
        orderingName: artistDTO.artist.orderingName,
        spotifyId: artistDTO.artist.spotifyId,
        tags: createBaseTagsListFromDataClasses(artistDTO.tags).toSet());
  }

  Artist? createArtistFromOptionalDTO(ArtistWithTagsDTO? artistDTO) {
    if (artistDTO == null) return null;
    return createArtistFromDTO(artistDTO);
  }

  List<Artist> createArtistsListFromDTOs(List<ArtistWithTagsDTO> artistDtoList) {
    return artistDtoList.map(createArtistFromDTO).toList();
  }

  //
  // Tag
  //
  BaseTag createBaseTagFromDataClass(TagDataClass dataClass) {
    return BaseTag(id: dataClass.id, name: dataClass.name, colorMode: dataClass.colorMode);
  }

  List<BaseTag> createBaseTagsListFromDataClasses(List<TagDataClass> dataClassList) {
    return dataClassList.map(createBaseTagFromDataClass).toList();
  }

  Tag createTagFromDTO(TagWithDataDTO tagDTO) {
    return Tag(
        id: tagDTO.tag.id,
        name: tagDTO.tag.name,
        category: createTagCategoryFromDataClass(tagDTO.category),
        colorMode: tagDTO.tag.colorMode,
        frequency: tagDTO.frequency);
  }

  Tag? createTagFromOptionalDTO(TagWithDataDTO? tagDTO) {
    if (tagDTO == null) return null;
    return createTagFromDTO(tagDTO);
  }

  List<Tag> createTagsListFromDTOs(List<TagWithDataDTO> tagDtoList) {
    return tagDtoList.map(createTagFromDTO).toList();
  }

  TagDataClass convertTagToDataClass(Tag tag) {
    return TagDataClass(id: tag.id, name: tag.name, category: tag.category.id, colorMode: tag.colorMode);
  }

  //
  // Tag category
  //
  TagCategory createTagCategoryFromDataClass(TagCategoryDataClass dataClass) {
    return TagCategory(id: dataClass.id, name: dataClass.name, color: dataClass.color);
  }

  TagCategory? createTagCategoryFromOptionalDataClass(TagCategoryDataClass? dataClass) {
    if (dataClass == null) return null;
    return createTagCategoryFromDataClass(dataClass);
  }

  List<TagCategory> createTagCategoriesListFromDataClasses(List<TagCategoryDataClass> dataClassList) {
    return dataClassList.map(createTagCategoryFromDataClass).toList();
  }

  TagCategoryDataClass convertTagCategoryToDataClass(TagCategory tagCategory) {
    return TagCategoryDataClass(id: tagCategory.id, name: tagCategory.name, color: tagCategory.color);
  }

  //
  // LastFm account
  //
  LastFmAccount? createLastFmAccountFromOptionalDataClass(LastFmAccountDataClass? dataClass) {
    if (dataClass == null) return null;
    return LastFmAccount(
        name: dataClass.accountName,
        lastAccountUpdate: dataClass.lastAccountUpdate,
        lastTopArtistsUpdate: dataClass.lastTopArtistsUpdate);
  }

  LastFmAccountDataClass convertLastFmAccountToDataClass(LastFmAccount lastFmAccount) {
    return LastFmAccountDataClass(
        accountName: lastFmAccount.name,
        lastAccountUpdate: lastFmAccount.lastAccountUpdate,
        lastTopArtistsUpdate: lastFmAccount.lastTopArtistsUpdate);
  }
}
