import token_ERC721 from 'ic:canisters/token_ERC721';

token_ERC721.greet(window.prompt("Enter your name:")).then(greeting => {
  window.alert(greeting);
});
