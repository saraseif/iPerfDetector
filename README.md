# Replication Package for iPerfDetector: Characterizing and Detecting Performance Anti-patterns in iOS Applications

Sara Seif Afjehei, Tse-Hsun (Peter) Chen, Nikolaos Tsantalis

Abstract: Performance issues in mobile applications (i.e., apps) often have a direct impact on the user experience. However, due to limited testing resources and fast-paced software development cycles, many performance issues remain undiscovered when the apps are released. As found by a prior study, these performance issues are one of the most common complaints that app users have. Unfortunately, there is limited support to help developers avoid or detect
performance issues in mobile apps.
In this paper, we conduct an empirical study on performance issues in iOS apps written in Swift language. To the best of our knowledge, this is the first study on performance issues of apps on the iOS platform. We manually studied 235 performance issues that are collected from four open source iOS apps. We found that most performance issues in iOS apps are related to inefficient UI design, memory issues, and inefficient thread handling. We also manually uncovered four performance anti-patterns that recurred in the studied issue reports. To help developers avoid these performance anti-patterns in the code, we implemented a static analysis tool called iPerfDetector.We evaluated iPerfDetector on eight open source and three commercial apps. iPerfDetector successfully detected 34 performance anti-pattern instances in the studied apps, where 31 of them are already confirmed and accepted by developers as potential performance issues. Our case study on the performance impact of the anti-patterns shows that fixing the anti-pattern may improve the performance


## Tools
SwiftAST [GitHub](https://github.com/yanagiba/swift-ast)

## Standalone Tool

To use it as a standalone tool, clone this repository to your local machine by

```bash
git clone https://github.com/saraseif/iPerfDetector
```

SwiftAST is the static analysis tool used in this tool. Instructions are accordingly:
Go to the repository folder and run the following command:

```bash
swift build -c release
```

This will generate a `swift-ast` executable inside `.build/release` folder.

## Manual Study Results
The manually annotated issue reports that we studied are publicly available at:
https://docs.google.com/spreadsheets/d/1hX8IBcYIVv6x4nWfWczT5oLV0b1SMQK03q6_xC9B8eQ/edit#gid=1079185239

