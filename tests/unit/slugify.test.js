'use strict';

const test = require('node:test');
const assert = require('node:assert/strict');
const { slugify } = require('../../src/slugify');

test('happy path', () => {
  assert.equal(slugify('Hello World'), 'hello-world');
});

test('strips accents and punctuation', () => {
  assert.equal(slugify('Ação rápida: já!'), 'acao-rapida-ja');
});

test('edge: empty and symbol-only input', () => {
  assert.equal(slugify(''), '');
  assert.equal(slugify('!!!'), '');
});

test('edge: truncates without a trailing dash', () => {
  assert.equal(slugify('abc def', { maxLength: 4 }), 'abc');
});

test('failure: rejects non-string input', () => {
  assert.throws(() => slugify(null), TypeError);
});
