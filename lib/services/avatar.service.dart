import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AvatarService {
  Image placeHolder = Image(image: AssetImage('assets/avataaars.png'));

  Widget getGreetingAvatar({double width = 64, double height = 64}) {
    const String avatarUrl =
        'https://avataaars.io/?avatarStyle=Transparent&topType=LongHairStraight&accessoriesType=Blank&hairColor=Black&facialHairType=Blank&clotheType=BlazerShirt&eyeType=Happy&eyebrowType=Default&mouthType=Smile&skinColor=Brown';

    return SvgPicture.network(
      avatarUrl,
      width: width,
      height: height,
      placeholderBuilder: (context) => placeHolder,
    );
  }

  Widget getDefaultAvatar({double width = 64, double height = 64}) {
    return Image(
      image: AssetImage('assets/avataaars.png'),
      width: width,
      height: height,
    );
  }

  Widget getMaleAvatar({double width = 64, double height = 64}) {
    const String avatarUrl =
        'https://avataaars.io/?avatarStyle=Transparent&topType=ShortHairDreads01&accessoriesType=Blank&hairColor=Black&facialHairType=BeardLight&facialHairColor=Black&clotheType=Hoodie&clotheColor=Gray02&eyeType=Happy&eyebrowType=Default&mouthType=Smile&skinColor=Brown';

    return SvgPicture.network(
      avatarUrl,
      width: width,
      height: height,
      placeholderBuilder: (context) => placeHolder,
    );
  }
}
