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
        this.innerHTML = '<ol class="chapter"><li class="chapter-item expanded "><a href="index.html"><strong aria-hidden="true">1.</strong> はじめに</a></li><li class="chapter-item expanded "><a href="why_tcl_now.html"><strong aria-hidden="true">2.</strong> なぜ今さらTcl?</a></li><li class="chapter-item expanded "><a href="environment.html"><strong aria-hidden="true">3.</strong> 本書のサンプルの動作環境</a></li><li class="chapter-item expanded "><a href="evaluation_rule.html"><strong aria-hidden="true">4.</strong> Tcl インタープリターと評価のルール</a></li><li><ol class="section"><li class="chapter-item expanded "><a href="tcl_command.html"><strong aria-hidden="true">4.1.</strong> コマンド</a></li><li><ol class="section"><li class="chapter-item expanded "><a href="command_command_command.html"><strong aria-hidden="true">4.1.1.</strong> コマンドという語の多義性</a></li><li class="chapter-item expanded "><a href="tcl_list.html"><strong aria-hidden="true">4.1.2.</strong> word列と Tcl リスト</a></li></ol></li><li class="chapter-item expanded "><a href="comment.html"><strong aria-hidden="true">4.2.</strong> コメント</a></li><li class="chapter-item expanded "><a href="tcl_wordbreaking.html"><strong aria-hidden="true">4.3.</strong> インタープリタとコマンドのword分割</a></li><li><ol class="section"><li class="chapter-item expanded "><a href="puts.html"><strong aria-hidden="true">4.3.1.</strong> puts stdout</a></li><li class="chapter-item expanded "><a href="word_breaking_and_quoting.html"><strong aria-hidden="true">4.3.2.</strong> word分割とquote</a></li></ol></li><li class="chapter-item expanded "><a href="substitution.html"><strong aria-hidden="true">4.4.</strong> word内の置換</a></li><li class="chapter-item expanded "><a href="arg_expansion.html"><strong aria-hidden="true">4.5.</strong> wordの引数展開</a></li><li class="chapter-item expanded "><a href="tcl_interp_overall.html"><strong aria-hidden="true">4.6.</strong> インタープリタの役割（まとめ）</a></li><li class="chapter-item expanded "><a href="quote.html"><strong aria-hidden="true">4.7.</strong> quoteと置換の細かい話</a></li></ol></li><li class="chapter-item expanded "><a href="expr.html"><strong aria-hidden="true">5.</strong> サブ言語 Tcl 式（expr コマンド）</a></li><li class="chapter-item expanded "><a href="procedure.html"><strong aria-hidden="true">6.</strong> 手続き</a></li><li><ol class="section"><li class="chapter-item expanded "><a href="proc_var_scope.html"><strong aria-hidden="true">6.1.</strong> 変数のスコープ</a></li><li class="chapter-item expanded "><div><strong aria-hidden="true">6.2.</strong> デフォルト引数、可変長引数</div></li><li class="chapter-item expanded "><div><strong aria-hidden="true">6.3.</strong> 無名手続き apply</div></li></ol></li><li class="chapter-item expanded "><a href="scriptfile.html"><strong aria-hidden="true">7.</strong> Tcl スクリプトのファイル化</a></li><li><ol class="section"><li class="chapter-item expanded "><a href="executable_scriptfile.html"><strong aria-hidden="true">7.1.</strong> 実行可能なスクリプトファイル</a></li></ol></li><li class="chapter-item expanded "><div><strong aria-hidden="true">8.</strong> TclObjと内部表現</div></li><li class="chapter-item expanded "><div><strong aria-hidden="true">9.</strong> 名前空間</div></li><li class="chapter-item expanded "><div><strong aria-hidden="true">10.</strong> データ型とコマンド</div></li><li><ol class="section"><li class="chapter-item expanded "><div><strong aria-hidden="true">10.1.</strong> TclObjと内部表現</div></li><li class="chapter-item expanded "><div><strong aria-hidden="true">10.2.</strong> リスト</div></li><li class="chapter-item expanded "><div><strong aria-hidden="true">10.3.</strong> 文字列</div></li><li class="chapter-item expanded "><div><strong aria-hidden="true">10.4.</strong> 数値</div></li><li class="chapter-item expanded "><div><strong aria-hidden="true">10.5.</strong> ファイルとプロセス</div></li></ol></li><li class="chapter-item expanded "><div><strong aria-hidden="true">11.</strong> サブ・インタープリター</div></li><li class="chapter-item expanded "><div><strong aria-hidden="true">12.</strong> snit</div></li><li class="chapter-item expanded "><a href="appendix.html"><strong aria-hidden="true">13.</strong> 付録</a></li><li><ol class="section"><li class="chapter-item expanded "><a href="comparison_with_bash.html"><strong aria-hidden="true">13.1.</strong> bashとの比較</a></li></ol></li></ol>';
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
