# Policy for admission to, rejection from, and removal from the repository

1. Open Source Licensing

    All apps must be released under a valid [OSI-approved open source license](https://opensource.org/licenses).

    The license must be clearly stated in the source repository (e.g., in a LICENSE file).

2. Functionality & Usefulness

    The app should have a meaningful use case, not just a “Hello World”.

    Basic level of usability—doesn’t have to be pretty, but shouldn’t be broken.

3. Public Repository with Clear History

    The source code must be hosted in a public version control system (e.g., [GitHub](https://github.com/), [GitLab](https://about.gitlab.com/), [Codeberg](https://codeberg.org/)).

    The repository should have a clear commit history. Apps with only one or two initial commits and no meaningful development will be excluded.

    Forks are allowed only if they show active and significant development beyond the original.

4. Actively Maintained

    The app must show signs of active maintenance, such as commits, pull requests, or issue discussions within the last six months.

    Projects without meaningful updates in that timeframe may be flagged as “archived” or removed.

5. No Ads or Monetization Tracking

    Apps must be free of advertisements. No trackers or analytics with the goal of monetization for the author or for a related third-party. Example, [Giphy](https://giphy.com/) has an [SDK](https://developers.giphy.com/docs/sdk/) with a tracker and analytics. It is not implemented in a way the author or anyone other than [Giphy](https://giphy.com/) could use it for monetization purposes. Where as adding a tracker or analytics with the goal of collecting data about users for the purposes of making money off, by the author or related third-parties, that collection is not allowed.

    Donation or sponsorship links (e.g., GitHub Sponsors, Liberapay, Ko-fi, Buy me a Coffee, Pateron) are permitted if implemented in such a way as to not block the use of the app or any feature. Meaning no feature locking behind a paywall. No commerical software.

    If donations or any exchange of money, in any form to the author or related third-parties, affects the code, this is not allowed. An example, if it was a client to a service that requires you to pay for access, but that service is not the author or related third-party, that is OK. [Roo Code](https://github.com/RooCodeInc/Roo-Code), an open source client for any of the AI model APIs is a great example.

    Related third-parties mean a company, family member, etc that is assoicated with the author in such a way that the author might get indirect benefits or kickbacks from. Say the author's spouse or relative that runs the company or service that the software uses. Even if the party isn't directly related, if the company pays a kickback, finder fee, commission, or any form of exchange of money.

6. Malware-Free

    Apps must not contain malicious code, spyware, or abusive behavior (e.g., data harvesting, location tracking without consent).

    Code must not depend on obfuscated libraries that could introduce untrusted functionality. Proprietary libraries are allowed, as long as they would be usable by virtually anyone, and are things like SDKs used for accessing a certain API.
