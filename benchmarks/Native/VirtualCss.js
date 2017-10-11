var _mdgriffith$style_elements$Native_VirtualCss = function() {
    
    const style = document.createElement('style');
    document.head.appendChild(style);

    function insert(rule, index)
    {
        var inserted = style.sheet.insertRule(rule, index);

        return inserted;
    }

    function remove(index)
    {
        var inserted = style.sheet.deleteRule(index);
        return inserted;
    }
   
    
    return {
        insert: F2(insert),
        delete: remove
    };
    
}();
    
    
    