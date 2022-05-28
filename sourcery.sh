#setopt extended_glob

sourcery \
--sources Moc \
--sources ~/Library/Developer/Xcode/DerivedData/Moc-*/SourcePackages/Checkouts/TDLibKit/Sources \
--templates Templates \
--output Moc/Generated
