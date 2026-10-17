const { test } = require('node:test');
const assert = require('node:assert/strict');
const fs = require('node:fs');
const vm = require('node:vm');

// A small DOM fixture keeps these checks dependency-free.
function element(text = '') {
  const classes = new Set();
  return {
    textContent: text, children: [], attrs: {},
    classList: { add: c => classes.add(c), remove: c => classes.delete(c), contains: c => classes.has(c) },
    setAttribute(k, v) { this.attrs[k] = v; },
    append(...nodes) { this.children.push(...nodes); },
    replaceChildren(...nodes) { this.children = nodes; },
  };
}

function load({ text = 'do { code; learn; sleep; } repeat;', reduced = false, missing = false } = {}) {
  const subtitle = element(text);
  const timers = [];
  const listeners = {};
  const motion = { matches: reduced, addEventListener: (_, fn) => { listeners.motion = fn; } };
  const document = {
    hidden: false, readyState: 'complete',
    querySelector: () => missing ? null : subtitle,
    createElement: () => element(),
    createTextNode: text => ({ textContent: text }),
    addEventListener: (name, fn) => { listeners[name] = fn; },
  };
  const context = { document, window: { matchMedia: () => motion },
    setTimeout: fn => { timers.push(fn); return timers.length; }, clearTimeout: () => { timers.length = 0; } };
  vm.runInNewContext(fs.readFileSync('assets/js/tagline.js', 'utf8'), context);
  return { subtitle, timers, listeners, motion, document };
}

test('cycles the tagline words while retaining a stable accessible label', () => {
  const { subtitle, timers } = load();
  assert.equal(subtitle.attrs['aria-label'], 'do { code; learn; sleep; } repeat;');
  assert.equal(subtitle.children[2].textContent, ' } repeat;');
  const rotating = subtitle.children[1];
  assert.equal(rotating.children[0].textContent, 'code;');
  timers.shift()();
  assert.equal(rotating.children[0].textContent, 'learn;');
  timers.shift()();
  assert.equal(rotating.children[0].textContent, 'sleep;');
  timers.shift()();
  assert.equal(rotating.children[0].textContent, 'code;');
});

test('keeps the static tagline for reduced motion and unexpected text', () => {
  for (const options of [{ reduced: true }, { text: 'A different tagline' }, { missing: true }]) {
    const { subtitle, timers } = load(options);
    assert.equal(timers.length, 0);
    assert.equal(subtitle.children.length, 0);
  }
});

test('stops motion when the user enables reduced motion', () => {
  const { subtitle, timers, listeners, motion } = load();
  motion.matches = true;
  listeners.motion();
  assert.equal(timers.length, 0);
  assert.equal(subtitle.textContent, 'do { code; learn; sleep; } repeat;');
});

test('pauses the loop in a hidden tab and resumes when visible', () => {
  const { timers, listeners, document } = load();
  document.hidden = true;
  listeners.visibilitychange();
  assert.equal(timers.length, 0);
  document.hidden = false;
  listeners.visibilitychange();
  assert.equal(timers.length, 1);
});
