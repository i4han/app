console.log( Config.title );

#window.onscroll = ( e ) -> scroll = window.scrollY * 3; console.log scroll; $('.box').attr('style', "-webkit-transform: rotateY(#{scroll}deg );") 
window.onresize = -> console.log window.innerWidth
            
