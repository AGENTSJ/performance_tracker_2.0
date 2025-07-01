import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AvatarService {
  static const String Avatar_Character = "You are not too overly enthusiastic ,honest and has a sarcastic funny and pointed at flaws sound to it but it should not affect the way text is seen";
  Image placeHolder = Image(image: AssetImage(
    'assets/avataaars.png',
  ));

  Widget getGreetingAvatar({
    double width = 64,
    double height = 64,
  }) {
    const String avatarUrl =
        'https://avataaars.io/?avatarStyle=Transparent&topType=LongHairStraight&accessoriesType=Blank&hairColor=Black&facialHairType=Blank&clotheType=BlazerShirt&eyeType=Happy&eyebrowType=Default&mouthType=Smile&skinColor=Brown';

    return SvgPicture.network(
      avatarUrl,
      width: width,
      height: height,
      placeholderBuilder: (context) => placeHolder,
    );
  }

  Widget getDefaultAvatar(
    {
      double width = 64,
      double height = 64
    }
  )
  {
    
    return Image(image: AssetImage('assets/avataaars.png'),width: width,height: height,);
  }
}