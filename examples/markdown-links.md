# Markdown link examples

Use this document as a reference and a manual test file for the Markdown link mapping.

## Test procedure

1. Open this file in Neovim.
2. Enter normal mode.
3. Put the cursor on any link text.
4. Press `<CR>`.
5. Press `<C-o>` to return after a Neovim jump.

The mapping does nothing when the cursor is not on a supported link.

## Internal heading links

These links jump to headings in this document.

- [Internal target](#internal-target)
- [Heading with punctuation](#part-1--punctuation)
- [First repeated heading](#repeated-heading)
- [Second repeated heading](#repeated-heading-1)

## File links

These links open files with the same behavior as `gf`.

- [README with an extension](../README.md)
- [README without an extension](../README)
- [README with an angle-bracket destination](<../README.md>)
- [README Notes heading](../README.md#notes)

## Wikilinks

These links use the configured `.md` suffix.

- [[../README]]
- [[../README|README with an alias]]

## Web and URI links

These links open with the system handler, as `gx` does.

- [HTTPS link](https://example.com/)
- [HTTP link](http://example.com/)
- [URL with parentheses](https://en.wikipedia.org/wiki/Neovim_(text_editor))
- [FTP link](ftp://example.com/)
- [Email link](mailto:test@example.com)
- <https://example.com/autolink>
- https://example.com/bare-url
- mailto:test@example.com

## No-link behavior

This line has no link.

Put the cursor on the line above. Press `<CR>`. The cursor does not move.

## Internal targets

### Internal target

The internal link opens this heading.

### Part 1 — Punctuation

The punctuation link includes a GitHub-style heading slug.

### Repeated heading

The first repeated-heading link opens this heading.

### Repeated heading

The second repeated-heading link opens this heading.
