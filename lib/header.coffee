
slice = (str) -> @_.slice str

# correct - id must unique.
sidebarMenu = (list, id='sidebar_menu') ->
    jade: -> @_.slice "each items|>+menu_list"
    helpers: 
    	items: -> list.map (a) -> { page:a, id:id } 

assignPopover = (o,v) -> 
    o['focus input#'+v] = -> 
        $('input#'+v)
            .attr('data-content', __.render 'popover_'+v)
            .popover 'show' 
        o

popover = (list) -> list.reduce ((o, v) -> assignPopover o, v), {}
