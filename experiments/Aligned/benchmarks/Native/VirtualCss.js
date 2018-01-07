var _mdgriffith$style_elements$Native_VirtualCss = function() {
    
    const style = document.createElement('style');
    document.head.appendChild(style);

    var size = 0

    function insert(rule, index)
    {
        size = size + 1
        return style.sheet.insertRule(rule, index);
    }

    function remove(index)
    {
        size = size - 1
        return style.sheet.deleteRule(index);
    }
   
    function clear(token)
    {
        if (size == 0) {
            return []
        } else {

            for (var i = 0; i < size; i++) {
                // i is your integer
                style.sheet.deleteRule(i);
            }
            size = 0;
        }
        return []
    }
    
    return {
        insert: F2(insert),
        delete: remove,
        clear: clear
    };
    
}();
