#!/usr/bin/env python2.7

from bs4 import BeautifulSoup

# Open HTML file
doc = BeautifulSoup(open('input.html'))

# Prepare array to store data
entries = []

# Find all 'h1' tags
for section in doc.find_all('h1'):

  # Get header text
  header = section.find_all(text=True)[0].split('.')

  # Get paragraph content
  # ... don't forget about Unicode
  content = u""

  # Find next tag
  for p in section.find_next_siblings():

    # ... if it's 'h1' tag - then stop, as we reached next header
    if p.name == 'h1':
      break

    # We can do some HTML cleanup here
    # ... remove 'span' tags
    if p.span:
      p.span.unwrap()
    # ... delete paragraph class
    del p['class']

    # Take care of newline characters
    # ... and tell Python to treat it as Unicode
    content += unicode(p).replace("\n", u' ')

    # Newline tag to properly separate paragraphs
    content += '<br/>'

  # Add new header plus its content into array
  entries.append({ 'header': header, 'content': content})

# Show the result
print(entries)
