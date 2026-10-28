(() => {
  const toggle = document.querySelector('.nav-menu-toggle');
  const nav = document.getElementById('primaryNavLinks');
  const mobileQuery = window.matchMedia('(max-width: 1180px)');
  if (!toggle || !nav) return;

  const closeDropdowns = () => nav.querySelectorAll('.nav-dropdown[open]').forEach(dropdown => dropdown.removeAttribute('open'));
  const closeMenu = ({returnFocus = false, closeDetails = true} = {}) => {
    nav.classList.remove('is-open');
    toggle.setAttribute('aria-expanded', 'false');
    toggle.setAttribute('aria-label', 'Open navigation menu');
    if (closeDetails) closeDropdowns();
    if (returnFocus && mobileQuery.matches) toggle.focus();
  };
  const openMenu = () => {
    nav.classList.add('is-open');
    toggle.setAttribute('aria-expanded', 'true');
    toggle.setAttribute('aria-label', 'Close navigation menu');
  };

  toggle.addEventListener('click', () => {
    const isOpen = nav.classList.contains('is-open');
    if (isOpen) closeMenu();
    else openMenu();
  });

  // Keep dropdowns mutually exclusive and close the mobile menu after navigation.
  nav.querySelectorAll('.nav-dropdown').forEach(dropdown => {
    dropdown.addEventListener('toggle', () => {
      if (!dropdown.open) return;
      nav.querySelectorAll('.nav-dropdown[open]').forEach(other => {
        if (other !== dropdown) other.removeAttribute('open');
      });
    });
  });
  nav.addEventListener('click', event => {
    const link = event.target.closest('a');
    if (!link) return;
    if (mobileQuery.matches) closeMenu();
  });

  document.addEventListener('click', event => {
    if (!mobileQuery.matches) {
      const openDropdown = nav.querySelector('.nav-dropdown[open]');
      if (openDropdown && !openDropdown.contains(event.target)) openDropdown.removeAttribute('open');
      return;
    }
    if (nav.classList.contains('is-open') && !nav.contains(event.target) && !toggle.contains(event.target)) closeMenu();
  });

  document.addEventListener('keydown', event => {
    if (event.key !== 'Escape') return;
    const openedDropdown = nav.querySelector('.nav-dropdown[open]');
    if (openedDropdown) {
      openedDropdown.removeAttribute('open');
      const summary = openedDropdown.querySelector('summary');
      if (summary) summary.focus();
      return;
    }
    if (nav.classList.contains('is-open')) closeMenu({returnFocus: true});
  });

  const onBreakpointChange = event => {
    if (!event.matches) closeMenu();
    closeDropdowns();
  };
  if (typeof mobileQuery.addEventListener === 'function') mobileQuery.addEventListener('change', onBreakpointChange);
  else mobileQuery.addListener(onBreakpointChange);
  window.addEventListener('resize', () => {
    if (!mobileQuery.matches) closeMenu();
  });
})();
