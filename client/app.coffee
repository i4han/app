Sat.init();

Router.map -> 
    this.route 'home', path: '/'
    this.route 'x3d' 
    this.route 'help'
    this.route 'profile'

#window.onscroll = ( e ) -> scroll = window.scrollY * 3; console.log scroll; $('.box').attr('style', "-webkit-transform: rotateY(#{scroll}deg );") 
window.onresize = -> console.log window.innerWidth
            
