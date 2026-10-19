'use strict';

/** Turn a title into a URL slug: lowercase ASCII, words joined by "-". */
function slugify(text, { maxLength = 60 } = {}) {
  if (typeof text !== 'string') throw new TypeError('text must be a string');
  return text
    .normalize('NFKD')
    .replace(/[̀-ͯ]/g, '') // strip accents
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, '_')
    .replace(/^-+|-+$/g, '')
    .slice(0, maxLength)
    .replace(/-+$/, '');
}

module.exports = { slugify };
