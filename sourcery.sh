#!/bin/zsh

setopt extended_glob

sourcery \
--sources . \
--sources ~/Library/Developer/Xcode/DerivedData/Moc-*/SourcePackages/Checkouts/TDLibKit/Sources \
--templates Templates \
--output Moc/Generated
