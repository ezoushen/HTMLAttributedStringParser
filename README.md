# HTMLAttributedStringParser

This package is designed for converting html text to `NSAttributedString`. You should only consider using this package while `NSAttributedString(data:options:documentAttributes:)` does not meet your requirements.

`HTMLAttributedStringParser` gives you more control of the string parsing, it allows you to customize your own attribute and tag renderers. Howerver, it provides very limited pre-defined renderers for now, so you can consider it as a framework for you to  render your own attributed string from html text. 
