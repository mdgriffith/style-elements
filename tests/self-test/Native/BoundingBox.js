var _mdgriffith$style_elements$Native_BoundingBox = function() {

function getBoundingBox(id)
{
    var element = document.getElementById(id);
    if (element !== null){
        var bbox = element.getBoundingClientRect();
        var box = {
            width: bbox.width,
            height: bbox.height,
            left: bbox.left,
            top: bbox.top,
            right: bbox.right,
            bottom: bbox.bottom
        }

        return box;
    } else {
        console.log("No element found: #" + id);
        var box = {
            width: 0,
            height: 0,
            left: 0,
            top: 0,
            right: 0,
            bottom: 0
        }

        return box;
    }
}
function documentSize(unit)
{
    var size = {
        width: document.body.scrollWidth,
        height: document.body.scrollHeight
    }
    return size;
}

return {
    getBoundingBox: getBoundingBox,
    documentSize: documentSize
};

}();



