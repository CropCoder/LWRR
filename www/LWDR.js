document.addEventListener("DOMContentLoaded", function(event) {
        var hash = window.location.hash;
        if (hash) {
          setTimeout(function() {
            var element = document.querySelector(hash);
            if (element) {
              element.scrollIntoView({behavior: "smooth"});
            }
          }, 100); // 等待 Shiny 内容加载完成
        }
      });

// custom.js

// 在页面加载完成后执行
$(document).ready(function() {
    // 监听SVG编辑器中的保存按钮点击事件
    $("#saveBtn").on("click", function() {
        // 获取SVG内容
        var svgContent = svgCanvas.getSvgString();

        // 将SVG内容发送到Shiny
        Shiny.setInputValue("svgContent", svgContent);
    });
});