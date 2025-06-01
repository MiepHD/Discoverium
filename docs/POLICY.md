# Policy for admission to, rejection from, and removal from the repository

1. Open Source Licensing
All apps must be released under a valid OSI-approved open source license.

The license must be clearly stated in the source repository (e.g., in a LICENSE file).

2. Functionality & Usefulness
The app should have a meaningful use case, not just a “Hello World.”

Basic level of usability—doesn’t have to be pretty, but shouldn’t be broken.

3. Public Repository with Clear History
The source code must be hosted in a public version control system (e.g., GitHub, GitLab, Codeberg).

The repository should have a clear commit history. Apps with only one or two initial commits and no meaningful development will be excluded.

Forks are allowed only if they show active and significant development beyond the original.

4. Actively Maintained
The app must show signs of active maintenance, such as commits, pull requests, or issue discussions within the last six months.

Projects without meaningful updates in that timeframe may be flagged as “archived” or removed.

5. No Ads or Monetization Tracking
Apps must be free of advertisements. No trackers or analytics with the goal of monetization for the author or for a related third-party. Example, Giphy has an SDK with a tracker and analytics. It is not implemented in a way the author or anyone other than Giphy could use it for monetization purposes. Where as adding a tracker or analytics with the goal of collecting data about users for the purposes of making money off, by the author or related third-parties, that collection is not allowed.

Donation or sponsorship links (e.g., GitHub Sponsors, Liberapay, Ko-fi, Buy me a Coffee, Pateron) are permitted if implemented in such a way as to not block the use of the app or any feature.

6. Malware-Free
Apps must not contain malicious code, spyware, or abusive behavior (e.g., data harvesting, location tracking without consent).

Code must not depend on obfuscated libraries that could introduce untrusted functionality. Proprietary libraries are allowed, as long as they would be usable by virtually anyone, and are things like SDKs used for accessing a certain API.
