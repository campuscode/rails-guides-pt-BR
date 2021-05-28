document.addEventListener("DOMContentLoaded", () => {
  const prefersDarkScheme = window.matchMedia("(prefers-color-scheme: dark)");
  const currentTheme = localStorage.getItem("theme");
  const body = document.body
  const modeToggle = document.querySelector('#toggle');

  const toggleTheme = () => {
    modeToggle.classList.toggle('dark-mode');
    var theme = body.id == 'dark' ? "light" : "dark";
    body.id = theme
    localStorage.setItem("theme", theme);
  };

  if (currentTheme == "dark" || (!currentTheme && prefersDarkScheme.matches)) {
    toggleTheme();
  }

  modeToggle.addEventListener('click', () => {
    toggleTheme();
  })
})
