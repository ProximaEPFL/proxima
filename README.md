![Coverage Badge](https://img.shields.io/endpoint?url=https://gist.githubusercontent.com/gruvw/1009ca75162e4a39e4561300eadbc5c4/raw/proxima_badge.json)

# Proxima

**Discover the world, one post at a time!**

Although people get closer through social media, they are physically farther than ever, so we present you Proxima.

Imagine a social app that encourages people to visit interesting places instead of staying at home.
It allows people to share posts, but with a catch: one has to physically move to the place the post was published in order to read it.

## Core Functionality

- **Split App Model**: Utilizes Google Firebase for storing and retrieving posts and comments, ensuring content is up-to-date and accessible.
- **User Support**: Requires account creation for posting (Google Sign-In), promoting a secure and personalized user experience.
- **Sensor Use**: Integrates GPS tracking to display posts within 100m of the user's current location, making content relevant and localized.
- **Offline Mode**: Caches posts for offline access, allowing users to view nearby content without an internet connection.

## User Interface Design

Link to the [Mockup](https://design.penpot.app/#/view/93d0ad32-dfe5-8194-8004-0171998eeabe?page-id=76cd5706-e69f-8069-8004-1a1578d3f0c7&section=interactions&index=40&share-id=2bf3009f-0e08-815c-8004-2f94bccac32f) (view mode only).

Link to the [Wireframe](https://design.penpot.app/#/view/93d0ad32-dfe5-8194-8004-0171998eeabe?page-id=93d0ad32-dfe5-8194-8004-0171998eeabf&section=interactions&index=20&share-id=a9010c45-753d-8133-8004-2d800e7a903a) (view mode only).

Link to the [Penpot Project](https://design.penpot.app/#/workspace/43442e9d-d45f-8169-8004-017078780238/93d0ad32-dfe5-8194-8004-0171998eeabe).

## Project Architecture Diagram

Here is the first architecture diagram of the application for MS1.
This should give a quick reference/overview on the overall architecture and the relations between the different screens, data sources, and internal state of the application.

<img src="https://github.com/ProximaEPFL/proxima/assets/63407038/ce7aefae-9354-4f6c-bced-2165c0190417" alt="Proxima Arichtecture Diagram" width="600">
