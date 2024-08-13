var ele_banner = document.getElementById('banner');
function getBanner() {
  var match = ele_banner.style.backgroundImage.match(/url\(.*?\)/);
  if (match) { return match[0].slice(5, -2); }
}
function setBanner(path) {
  ele_banner.style.backgroundImage = `url(${path})`;
}
function getRandomArrayElement(array) {
  return array[Math.floor(Math.random() * array.length)];
}
function getArrayElementByNow(array, interval = 1440) {
  var date = new Date();
  var time = (date.getTime() / 60000 + date.getTimezoneOffset()) / interval;
  return array[Math.floor(time) % array.length];
}
function switchArrayElement(array, element, step = 1) {
  var index = array.indexOf(element);
  if (index === -1) { return array[0]; }
  index += step;
  while (index < 0) { index += array.length; }
  return array[index % array.length];
}
function isValidEventElement(element) {
  var ele_scrollbar = ele_banner.getElementsByClassName('scroll-down-bar')[0];
  return !(ele_scrollbar && ele_scrollbar.contains(element));
}
