/* Progressively enhance the masthead subtitle; its source remains readable. */
(function () {
  'use strict';

  function setupAnimation(subtitle) {
    if (!subtitle) return;
    var original = subtitle.textContent;
    var parts = original.match(/^(.*?\{\s*)([^{}]+?)(\s*\}.*)$/);
    if (!parts) return;
    var words = parts[2].trim().split(/\s+/);
    if (words.length < 2) return;
    var motion = window.matchMedia('(prefers-reduced-motion: reduce)');
    var timer;
    var index = 0;
    var word;

    function stop() {
      clearTimeout(timer);
      timer = null;
    }

    function schedule() {
      if (!document.hidden && !motion.matches) timer = setTimeout(advance, 2300);
    }

    function advance() {
      index = (index + 1) % words.length;
      word.textContent = words[index];
      if (word.animate) word.animate([
        { opacity: 0, transform: 'translateX(0.6em)' },
        { opacity: 1, transform: 'translateX(0)' }
      ], { duration: 300, easing: 'ease-out' });
      schedule();
    }

    function render() {
      stop();
      if (motion.matches) {
        subtitle.textContent = original;
        subtitle.classList.remove('tagline-animated');
        return;
      }
      subtitle.setAttribute('aria-label', original);
      var head = document.createElement('span');
      head.textContent = parts[1];
      var soup = document.createElement('span');
      soup.className = 'tagline-soup';
      word = document.createElement('span');
      word.className = 'tagline-word';
      word.textContent = words[index];
      soup.append(word);
      var tail = document.createElement('span');
      tail.textContent = parts[3];
      [head, soup, tail].forEach(function (node) { node.setAttribute('aria-hidden', 'true'); });
      subtitle.replaceChildren(head, soup, tail);
      subtitle.classList.add('tagline-animated');
      schedule();
    }

    motion.addEventListener('change', render);
    document.addEventListener('visibilitychange', function () { stop(); schedule(); });
    render();
  }

  function init() { setupAnimation(document.querySelector('.site-subtitle')); }
  if (document.readyState === 'loading') document.addEventListener('DOMContentLoaded', init);
  else init();
}());
