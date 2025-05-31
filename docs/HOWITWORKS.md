# Discoverium

## How it works
1. App authors put a `discoverium.yml` in their git repository

Example:
```
app:
  name: Slide
  authors: Nathan Grennan
  category: social
  description: Slide is an open-source, ad-free Reddit browser for Android. It is based around the Java Reddit API Wrapper.
  icon: https://raw.githubusercontent.com/cygnusx-1-org/Slide/refs/heads/master/app/src/main/res/mipmap-xxxhdpi/ic_launcher_round.png
  releases:
    url: https://github.com/cygnusx-1-org/Slide/releases
```

Required fields:
```
name
authors
category
description
icon
releases url
```

Find categories [here](https://github.com/cygnusx-1-org/Discoverium/blob/main/repo/categories.yml).

2. A [script](https://github.com/cygnusx-1-org/Discoverium/blob/main/scripts/build_repo.sh) retrieves all the URLs listed in [apps.yml](https://github.com/cygnusx-1-org/Discoverium/blob/main/apps.yml) and assembles it into [repo/apps.yml](https://github.com/cygnusx-1-org/Discoverium/blob/main/repo/apps.yml).

3. [Discoverium](https://github.com/cygnusx-1-org/Discoverium) loads [repo/apps.yml](https://github.com/cygnusx-1-org/Discoverium/blob/main/repo/apps.yml) and populates the list.
