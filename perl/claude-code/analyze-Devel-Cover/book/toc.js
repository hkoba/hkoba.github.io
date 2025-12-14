// Populate the sidebar
//
// This is a script, and not included directly in the page, to control the total size of the book.
// The TOC contains an entry for each page, so if each page includes a copy of the TOC,
// the total size of the page becomes O(n**2).
class MDBookSidebarScrollbox extends HTMLElement {
    constructor() {
        super();
    }
    connectedCallback() {
        this.innerHTML = '<ol class="chapter"><li class="chapter-item expanded "><div><strong aria-hidden="true">1.</strong> このプロジェクトは pjcj さんの作った Perl モジュール Devel::Cover のプロジ</div></li><li><ol class="section"><li class="chapter-item expanded "><a href="turn_1_user.html"><strong aria-hidden="true">1.1.</strong> User</a></li><li class="chapter-item expanded "><a href="turn_1_tool_2.html"><strong aria-hidden="true">1.2.</strong> Assistant (Tools 2)</a></li><li class="chapter-item expanded "><a href="turn_1_text_3.html"><strong aria-hidden="true">1.3.</strong> Assistant (Text 3)</a></li><li class="chapter-item expanded "><a href="turn_1_tool_4.html"><strong aria-hidden="true">1.4.</strong> Assistant (Tools 4)</a></li><li class="chapter-item expanded "><a href="turn_1_text_5.html"><strong aria-hidden="true">1.5.</strong> Assistant (Text 5)</a></li></ol></li><li class="chapter-item expanded "><div><strong aria-hidden="true">2.</strong> ありがとうございます。私の最終的な目的は、（カバレッジを取ることではなく）Perl のソースコードか</div></li><li><ol class="section"><li class="chapter-item expanded "><a href="turn_2_user.html"><strong aria-hidden="true">2.1.</strong> User</a></li><li class="chapter-item expanded "><a href="turn_2_tool_2.html"><strong aria-hidden="true">2.2.</strong> Assistant (Tools 2)</a></li><li class="chapter-item expanded "><a href="turn_2_text_3.html"><strong aria-hidden="true">2.3.</strong> Assistant (Text 3)</a></li><li class="chapter-item expanded "><a href="turn_2_tool_4.html"><strong aria-hidden="true">2.4.</strong> Assistant (Tools 4)</a></li><li class="chapter-item expanded "><a href="turn_2_text_5.html"><strong aria-hidden="true">2.5.</strong> Assistant (Text 5)</a></li><li class="chapter-item expanded "><a href="turn_2_tool_6.html"><strong aria-hidden="true">2.6.</strong> Assistant (Tools 6)</a></li><li class="chapter-item expanded "><a href="turn_2_text_7.html"><strong aria-hidden="true">2.7.</strong> Assistant (Text 7)</a></li><li class="chapter-item expanded "><a href="turn_2_tool_8.html"><strong aria-hidden="true">2.8.</strong> Assistant (Tools 8)</a></li><li class="chapter-item expanded "><a href="turn_2_text_9.html"><strong aria-hidden="true">2.9.</strong> Assistant (Text 9)</a></li><li class="chapter-item expanded "><a href="turn_2_tool_10.html"><strong aria-hidden="true">2.10.</strong> Assistant (Tools 10)</a></li><li class="chapter-item expanded "><a href="turn_2_text_11.html"><strong aria-hidden="true">2.11.</strong> Assistant (Text 11)</a></li></ol></li><li class="chapter-item expanded "><div><strong aria-hidden="true">3.</strong> ありがとうございます。やはり Devel::Cover は実行時の情報をキャプチャーして活用している</div></li><li><ol class="section"><li class="chapter-item expanded "><a href="turn_3_user.html"><strong aria-hidden="true">3.1.</strong> User</a></li><li class="chapter-item expanded "><a href="turn_3_tool_2.html"><strong aria-hidden="true">3.2.</strong> Assistant (Tools 2)</a></li><li class="chapter-item expanded "><a href="turn_3_text_3.html"><strong aria-hidden="true">3.3.</strong> Assistant (Text 3)</a></li><li class="chapter-item expanded "><a href="turn_3_tool_4.html"><strong aria-hidden="true">3.4.</strong> Assistant (Tools 4)</a></li><li class="chapter-item expanded "><a href="turn_3_text_5.html"><strong aria-hidden="true">3.5.</strong> Assistant (Text 5)</a></li><li class="chapter-item expanded "><a href="turn_3_tool_6.html"><strong aria-hidden="true">3.6.</strong> Assistant (Tools 6)</a></li><li class="chapter-item expanded "><a href="turn_3_text_7.html"><strong aria-hidden="true">3.7.</strong> Assistant (Text 7)</a></li><li class="chapter-item expanded "><a href="turn_3_tool_8.html"><strong aria-hidden="true">3.8.</strong> Assistant (Tools 8)</a></li><li class="chapter-item expanded "><a href="turn_3_text_9.html"><strong aria-hidden="true">3.9.</strong> Assistant (Text 9)</a></li></ol></li></ol>';
        // Set the current, active page, and reveal it if it's hidden
        let current_page = document.location.href.toString().split("#")[0];
        if (current_page.endsWith("/")) {
            current_page += "index.html";
        }
        var links = Array.prototype.slice.call(this.querySelectorAll("a"));
        var l = links.length;
        for (var i = 0; i < l; ++i) {
            var link = links[i];
            var href = link.getAttribute("href");
            if (href && !href.startsWith("#") && !/^(?:[a-z+]+:)?\/\//.test(href)) {
                link.href = path_to_root + href;
            }
            // The "index" page is supposed to alias the first chapter in the book.
            if (link.href === current_page || (i === 0 && path_to_root === "" && current_page.endsWith("/index.html"))) {
                link.classList.add("active");
                var parent = link.parentElement;
                if (parent && parent.classList.contains("chapter-item")) {
                    parent.classList.add("expanded");
                }
                while (parent) {
                    if (parent.tagName === "LI" && parent.previousElementSibling) {
                        if (parent.previousElementSibling.classList.contains("chapter-item")) {
                            parent.previousElementSibling.classList.add("expanded");
                        }
                    }
                    parent = parent.parentElement;
                }
            }
        }
        // Track and set sidebar scroll position
        this.addEventListener('click', function(e) {
            if (e.target.tagName === 'A') {
                sessionStorage.setItem('sidebar-scroll', this.scrollTop);
            }
        }, { passive: true });
        var sidebarScrollTop = sessionStorage.getItem('sidebar-scroll');
        sessionStorage.removeItem('sidebar-scroll');
        if (sidebarScrollTop) {
            // preserve sidebar scroll position when navigating via links within sidebar
            this.scrollTop = sidebarScrollTop;
        } else {
            // scroll sidebar to current active section when navigating via "next/previous chapter" buttons
            var activeSection = document.querySelector('#sidebar .active');
            if (activeSection) {
                activeSection.scrollIntoView({ block: 'center' });
            }
        }
        // Toggle buttons
        var sidebarAnchorToggles = document.querySelectorAll('#sidebar a.toggle');
        function toggleSection(ev) {
            ev.currentTarget.parentElement.classList.toggle('expanded');
        }
        Array.from(sidebarAnchorToggles).forEach(function (el) {
            el.addEventListener('click', toggleSection);
        });
    }
}
window.customElements.define("mdbook-sidebar-scrollbox", MDBookSidebarScrollbox);
