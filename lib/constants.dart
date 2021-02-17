import 'package:flutter/material.dart';

const textInputDecoration = InputDecoration(
  border: OutlineInputBorder(
    borderRadius: const BorderRadius.all(
      const Radius.circular(8.0),
    ),
  ),
  focusColor: Colors.blue,
  hintStyle: TextStyle(color: Colors.grey),
);

// interests
List<String> topics = [
  'Business',
  'Lifestyle',
  'Security',
  'Politics',
  'Environment',
  'Health',
  'Technology',
  'Religion',
  'News',
  'Spirituality',
  'Education',
  'Government',
  'Development',
  'History',
  'Culture',
  'Elections',
  'Jobs',
  'Sanitation',
  'Africa',
  'Europe',
  'Asia',
  'America',
  'Uncategorized'
];

// illustrations
const slider1Image = 'assets/illustrations/slider1.png';
const slider2Image = 'assets/illustrations/slider2.png';
const slider3Image = 'assets/illustrations/slider3.png';
const slider4Image = 'assets/illustrations/slider4.png';

// titles
const String slider1Title = 'Welcome to Comcent';
const String slider2Title = 'Join in the building';
const String slider3Title = 'Share with everyone';
const String slider4Title = '"We" & "Our"';

// descriptions
const String slider1Desc =
    '''Welcome to the first-ever community media platform.''';
const String slider2Desc =
    '''Join clubs to create new opportunities and contribute towards making your community a better place.''';
const String slider3Desc =
    '''Share ideas you wish to pitch to both the leaders and members of your community.''';
const String slider4Desc =
    '''Please do endeavor to always post with titles starting with either "We" or "Our" until you become a leader of your community. It provides a great sense of belongingness to the community.
       ''';

const String termsOfService = '''

Comcent Limited Terms of Service


1. Terms

By using this service, you warrant that you are at least 15 years of age. If you are below 15 years old, you are to seek permission from a parent or a guardian.

By installing and using Comcent, you are agreeing to be bound by these terms of service, all applicable laws and regulations, and agree that you are responsible for compliance with any applicable local laws. If you do not agree with any of these terms, you are prohibited from using or accessing this application. The information contained on Comcent are protected by applicable copyright and trademark law.

2. Use License

Permission is granted to temporarily copy the information on Comcent for personal, non-commercial transitory viewing only. This is the grant of a license, not a transfer of title, and under this license you may not:

a.	use the information for any commercial purpose, or for any public display (commercial or non-commercial);
b.	attempt to decompile or reverse engineer Comcent
c.	remove any copyright or other proprietary notations from the information; or
d.	transfer the information to another person or "mirror" the information on any other server.
This license shall automatically terminate if you violate any of these restrictions and may be terminated by Comcent Limited at any time. Upon terminating your viewing of these information  or upon the termination of this license, you must destroy any downloaded information in your possession whether in electronic or printed format.

3. Disclaimer

The information on Comcent are provided on an 'as is' basis. Comcent Limited makes no warranties, expressed or implied, and hereby disclaims and negates all other warranties including, without limitation, implied warranties or conditions of merchantability, fitness for a particular purpose, or non-infringement of intellectual property or other violation of rights.
Further, Comcent Limited does not warrant or make any representations concerning the accuracy, likely results, or reliability of the use of the information on Comcent or otherwise relating to such information or on any sites linked to Comcent.

4. Limitations

In no event shall Comcent Limited or its suppliers be liable for any damages (including, without limitation, damages for loss of data or profit, or due to business interruption) arising out of the use or inability to use the information on Comcent Limited' mobile application, even if Comcent Limited or a Comcent Limited authorized representative has been notified orally or in writing of the possibility of such damage. Because some jurisdictions do not allow limitations on implied warranties, or limitations of liability for consequential or incidental damages, these limitations may not apply to you.

5. Accuracy of information

The information appearing on Comcent could include technical, typographical, or photographic errors. Comcent Limited does not warrant that any of the information on Comcent is accurate, complete, or current.

6. Links

Comcent Limited has not reviewed all of the sites linked to Comcent Limited and is not responsible for the contents of any such linked site. The inclusion of any link does not imply endorsement by Comcent Limited of the site. Use of any such linked website is at the user's own risk.

7. Modifications

Comcent Limited may revise these terms of service for its mobile application at any time without notice. By using Comcent, you are agreeing to be bound by the then current version of these terms of service.

8. Governing Law

These terms and conditions are governed by and construed by the laws of Ghana and you irrevocably submit to the exclusive jurisdiction of the courts in the Republic of Ghana.


''';

const privacyPolicy = '''

Privacy Policy 


Welcome to Comcent.

Our Privacy Policy governs your use of the Comcent mobile application, and explains how we collect, safeguard, and disclose information that results from your use of our Service.
We use your data to provide and improve our Service. By using Comcent, you agree to the collection and use of information in accordance with this policy. Unless otherwise defined in this Privacy Policy, the terms used in this Privacy Policy have the same meanings as in our Terms and Conditions.
Our Terms and Conditions (“Terms”) govern all use of our Service and together with the Privacy Policy constitutes your agreement with us (“agreement”).

2. Information Collection and Use

We collect several different types of information for various purposes to provide and improve our Service to you.

3. Types of Data Collected

Personal Data

While using our Service, we may ask you to provide us with certain personally identifiable information that can be used to contact or identify you (“Personal Data”). Personally, identifiable information may include, but is not limited to:

a. Email address
b. First name and last name
c. Phone number
d. Profile Picture
e. Date Of Birth
g. Occupation 
h. Community you live in 

4. Use of Data

Comcent uses the collected data for various purposes:

a. to provide and maintain our Service;
b. to notify you about changes to our Service;
c. to allow you to participate in interactive features of our Service when you choose to do so;
d. to provide customer support;
e. to gather analysis or valuable information so that we can improve our Service;
f. to monitor the usage of our Service;
g. to detect, prevent and address technical issues;
h. to fulfill any other purpose for which you provide it;
i. to carry out our obligations and enforce our rights arising from any contracts entered into between you and us, including for billing and collection;
j. to provide you with notices about your account and/or subscriptionon, including expiration and renewal notices, email-instructions, etc.;
k. to provide you with news, special offers and general information about other goods, services and events which we offer that are similar to those that you have already purchased or enquired about unless you have opted not to receive such information;
l. in any other way we may describe when you provide the information;
m. for any other purpose that is in agreement with applicable law

5. Retention of Data

We will retain your Data only for as long as is necessary for the purposes set out in this Privacy Policy. We will retain and use your Data to the extent necessary to comply with our legal obligations (for example, if we are required to retain your data to comply with applicable laws), resolve disputes, and enforce our legal agreements and policies.
We will also retain Usage Data for internal analysis purposes. Usage Data is generally retained for a shorter period, except when this data is used to strengthen the security or to improve the functionality of our Service, or we are legally obligated to retain this data for longer periods.

6. Disclosure of Data

We may disclose personal information that we collect, or you provide:

a. Disclosure for Law Enforcement.
Under certain circumstances, we may be required to disclose your Data if required to do so by law or in response to valid requests by public authorities.

7. Security of Data

The security of your data is important to us but remember that no method of transmission over the Internet or method of electronic storage is 100% secure. While we strive to use commercially acceptable means to protect your Personal Data, we cannot guarantee its absolute security.

8. Changes to This Privacy Policy

We may update our Privacy Policy from time to time. We will notify you of any changes by posting the new Privacy Policy on this page.
We will let you know via email and/or a prominent notice on our Service, prior to the change becoming effective and update “effective date” at the top of this Privacy Policy.
You are advised to review this Privacy Policy periodically for any changes. Changes to this Privacy Policy are effective when they are posted on this page.



''';

String faqHeader =
    'FREQUENTLY ASKED QUESTIONS (FAQs) OF COMCENT – FIRST COMMUNITY MEDIA PLATFORM.';

List faqQuestions = [
  '1.	What is Comcent?',
  '2.	What is community media?',
  '3.	What are the benefits of Comcent to users?',
  '4.	Is Comcent free to use?',
  '5.	Who is the typical user of Comcent?',
  '6.	How are communities organized on Comcent?',
  '7.	How do our users create a blog post?',
  '8.	What differentiates a user who is a member from a user who is a leader?',
  '9.	Can a user who is a member become a leader on Comcent in the future?',
  '10.  Will Comcent be available in every community when it launched?',
  '11.	What are examples of community media platforms?'
];
List faqAnswers = [
  // answer 1
  '''Comcent is the first community media platform on earth. Comcent consist of two acronyms: com and cent. These two acronyms are from community and center respectively.''',

  // answer 2
  '''Rather than conversations taking place among family members, friends, and acquaintances, as it exists on social media platforms, community media platforms only allow conversations to take place between the leaders of a geographical community and the members of the same geographical community.''',

  // answer 3
  '''
  
  •	Comcent enables members of a community to share their grievances and concerns for it to be dealt with by those responsible. 

  •	Comcent enables leaders of a community to easily learn about the problems and concerns of their community.  

  •	Comcent helps users to form new connections in their community with the aid of its club property. 

  •	Comcent allows users to easily find information about their community.''',

  // answer 4
  '''Comcent is free to use for both members and leaders of every community in the world.''',

  // answer 5
  '''Comcent is for the person who has an interest in the discussions going on in his/her community and wishes to express his/her ideas – ideas that will improve the living standard of the community – only to the people in his/her community. ''',

  // answer 6
  '''

Communities are organized at Comcent the same way constituencies are organized in the real world. In other words, communities are used in the place of constituencies on the Comcent platform and each community has various subcommunities. For example, Ayawaso West Wougon is a name of a community on Comcent and it has subcommunities such as East Legon, Shiashie, American House, Bawaleshie, Okponglo, etc. In a completely different setting, University of Ghana is also a name of a community on Comcent and it has subccommunities such as Commonwealth Hall, Akuafo Hall, Mensah Sarbah Hall, Volta Hall, Legon Hall, etc. Ditto for other academic institutions.''',

  // answer 7
  '''

Users will first need to select a subcommunity during registration. They will choose between whether they are leaders or members of the subcommunity. Users who select as leaders will need to be verified before they can share blog posts. Every blog post has three parts: body, title, and topic. Users in different subcommunities but who belong to the same community will see the same timeline based on the topics they have selected.  ''',

  // answer 8
  '''

Users who are members of Comcent must compulsorily begin the title of their blog posts with either “we” or “our”. These restrictions apply to users who are members alone. Users who are leaders do not have these restrictions or any other restrictions. ''',

  // answer 9
  '''

Users who are members and are passionate about the progress of their community are rewarded on the Comcent platform. After a user who is a member has shared 400 blog posts, they are granted the privileges of a leader. ''',

  // answer 10
  '''

Comcent will be available at only the University of Ghana community when it is launched. However, we will quickly expand to other communities as soon as we launch. You can follow us on Twitter with the hashtag: #communitycenter''',

  // answer 11
  '''

Comcent occurs to be the first community media platform in the world as defined in literature. Management of Comcent Limited (the parent company of Comcent) is hopeful that new entrants will enter the market to make the community media market more competitive. '''
];
