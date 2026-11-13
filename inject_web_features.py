import os
import re

html_path = r"C:\Users\terra\.gemini\antigravity\scratch\it_adventures\build\web\index.html"

def inject_pwa_and_fullscreen():
    if not os.path.exists(html_path):
        print("index.html not found at", html_path)
        return

    with open(html_path, "r", encoding="utf-8") as f:
        html = f.read()

    # 1. PWA Meta Tags in <head>
    pwa_head = """
		<link rel="manifest" href="manifest.webmanifest">
		<meta name="mobile-web-app-capable" content="yes">
		<meta name="apple-mobile-web-app-capable" content="yes">
		<meta name="apple-mobile-web-app-status-bar-style" content="black-translucent">
		<meta name="apple-mobile-web-app-title" content="IT Adventures">
		<meta name="theme-color" content="#0f172a">
    """
    if 'manifest.webmanifest' not in html:
        html = html.replace('<head>', '<head>' + pwa_head)

    # 2. Service Worker for PWA
    sw_script = """
		<script>
		if ('serviceWorker' in navigator) {
			window.addEventListener('load', function() {
				navigator.serviceWorker.register('coi-serviceworker.min.js').catch(function(e) {});
			});
		}
		</script>
    """
    if 'serviceWorker.register' not in html:
        html = html.replace('</head>', sw_script + '\n\t</head>')

    # 3. HTML Buttons and Modal Overlay before </body>
    overlay_html = """
	<!-- Floating Web Action Bar for Fullscreen & Mobile Home Screen -->
	<div id="web-action-bar" style="position:fixed; top:10px; right:12px; z-index:9000; display:flex; gap:8px; pointer-events:auto;">
		<button id="web-btn-fullscreen" onclick="toggleFullscreen()" style="background:rgba(15,23,42,0.88); color:#38bdf8; border:1px solid #38bdf8; border-radius:18px; padding:6px 14px; font-family:-apple-system,BlinkMacSystemFont,Segoe UI,Roboto,sans-serif; font-size:12px; font-weight:600; cursor:pointer; backdrop-filter:blur(6px); box-shadow:0 3px 10px rgba(0,0,0,0.5); display:inline-flex; align-items:center; gap:5px;">
			<span>⛶</span> <span id="web-txt-fs">Pantalla Completa</span>
		</button>
		<button id="web-btn-share" onclick="triggerShareOrInstall()" style="background:rgba(15,23,42,0.88); color:#fbbf24; border:1px solid #fbbf24; border-radius:18px; padding:6px 14px; font-family:-apple-system,BlinkMacSystemFont,Segoe UI,Roboto,sans-serif; font-size:12px; font-weight:600; cursor:pointer; backdrop-filter:blur(6px); box-shadow:0 3px 10px rgba(0,0,0,0.5); display:inline-flex; align-items:center; gap:5px;">
			<span>📲</span> <span>Guardar en Pantalla</span>
		</button>
	</div>

	<!-- Modal Guía para Guardar en Pantalla de Inicio / Escritorio -->
	<div id="install-guide-modal" style="display:none; position:fixed; top:0; left:0; width:100%; height:100%; background:rgba(0,0,0,0.82); z-index:99999; justify-content:center; align-items:center; backdrop-filter:blur(8px); padding:20px; box-sizing:border-box;">
		<div style="background:#0f172a; border:2px solid #38bdf8; border-radius:14px; max-width:440px; width:100%; padding:22px; color:#f8fafc; font-family:-apple-system,BlinkMacSystemFont,Segoe UI,Roboto,sans-serif; box-shadow:0 12px 36px rgba(0,0,0,0.8); position:relative;">
			<h3 style="margin-top:0; color:#fbbf24; font-size:18px; display:flex; align-items:center; gap:8px;">
				<span>📲</span> Guardar IT Adventures en tu Teléfono
			</h3>
			<p style="font-size:13px; line-height:1.5; color:#cbd5e1; margin-bottom:14px;">
				Puedes guardar el juego como una aplicación directa en tu pantalla de inicio sin ocupar espacio de tienda:
			</p>
			<div style="background:rgba(30,41,59,0.8); border-radius:8px; padding:12px; margin-bottom:14px; font-size:12px; line-height:1.5; border-left:3px solid #38bdf8;">
				<b style="color:#38bdf8;">🍏 En iPhone / iPad (Safari):</b><br>
				1. Toca el botón <b>Compartir</b> (el icono con una flecha hacia arriba ⬆️ en la barra del navegador).<br>
				2. Desliza hacia abajo y elige <b>'Agregar a pantalla de inicio' (➕)</b>.<br>
				3. ¡Listo! Se abrirá en pantalla completa como una app nativa.
			</div>
			<div style="background:rgba(30,41,59,0.8); border-radius:8px; padding:12px; margin-bottom:16px; font-size:12px; line-height:1.5; border-left:3px solid #4ade80;">
				<b style="color:#4ade80;">🤖 En Android (Chrome):</b><br>
				1. Toca los <b>tres puntos</b> ⋮ arriba a la derecha.<br>
				2. Selecciona <b>'Instalar aplicación'</b> o <b>'Agregar a la pantalla principal'</b>.
			</div>
			<div style="display:flex; justify-content:flex-end;">
				<button onclick="closeInstallGuide()" style="background:#38bdf8; color:#0f172a; border:none; border-radius:8px; padding:8px 18px; font-weight:700; font-size:12px; cursor:pointer;">
					¡Entendido, volver al juego!
				</button>
			</div>
		</div>
	</div>

	<script>
	var deferredInstallPrompt = null;
	window.addEventListener('beforeinstallprompt', function(e) {
		e.preventDefault();
		deferredInstallPrompt = e;
		var btn = document.getElementById('web-btn-share');
		if (btn) {
			btn.innerHTML = '<span>📲</span> <span>Instalar en Teléfono</span>';
		}
	});

	function toggleFullscreen() {
		var doc = document.documentElement;
		var isFs = document.fullscreenElement || document.webkitFullscreenElement || document.mozFullScreenElement || document.msFullscreenElement;
		var txt = document.getElementById('web-txt-fs');
		if (!isFs) {
			if (doc.requestFullscreen) doc.requestFullscreen().catch(function(e){});
			else if (doc.webkitRequestFullscreen) doc.webkitRequestFullscreen();
			else if (doc.mozRequestFullScreen) doc.mozRequestFullScreen();
			else if (doc.msRequestFullscreen) doc.msRequestFullscreen();
			if (txt) txt.innerText = 'Salir Pantalla Completa';
		} else {
			if (document.exitFullscreen) document.exitFullscreen();
			else if (document.webkitExitFullscreen) document.webkitExitFullscreen();
			else if (document.mozCancelFullScreen) document.mozCancelFullScreen();
			else if (document.msExitFullscreen) document.msExitFullscreen();
			if (txt) txt.innerText = 'Pantalla Completa';
		}
	}

	document.addEventListener('fullscreenchange', function() {
		var isFs = !!(document.fullscreenElement || document.webkitFullscreenElement);
		var txt = document.getElementById('web-txt-fs');
		if (txt) {
			txt.innerText = isFs ? 'Salir Pantalla Completa' : 'Pantalla Completa';
		}
	});

	function triggerShareOrInstall() {
		if (deferredInstallPrompt) {
			deferredInstallPrompt.prompt();
			deferredInstallPrompt.userChoice.then(function(choice) {
				if (choice.outcome === 'accepted') {
					console.log('App install accepted');
				}
				deferredInstallPrompt = null;
			});
			return;
		}
		if (navigator.share) {
			navigator.share({
				title: 'IT Adventures RPG',
				text: '¡Juega IT Adventures! El RPG retro de Soporte Técnico en tu navegador.',
				url: window.location.href
			}).catch(function(e) {
				showInstallGuide();
			});
			return;
		}
		showInstallGuide();
	}

	function showInstallGuide() {
		var modal = document.getElementById('install-guide-modal');
		if (modal) modal.style.display = 'flex';
	}

	function closeInstallGuide() {
		var modal = document.getElementById('install-guide-modal');
		if (modal) modal.style.display = 'none';
	}
	</script>
    """

    if 'web-action-bar' not in html:
        html = html.replace('</body>', overlay_html + '\n\t</body>')

    with open(html_path, "w", encoding="utf-8") as f:
        f.write(html)

    print("Injected PWA and Fullscreen features into build/web/index.html successfully!")

if __name__ == "__main__":
    inject_pwa_and_fullscreen()
