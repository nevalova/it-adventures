import os
import re

html_path = r"C:\Users\terra\.gemini\antigravity\scratch\it_adventures\build\web\index.html"

def inject_pwa_and_fullscreen():
    if not os.path.exists(html_path):
        print("index.html not found at", html_path)
        return

    with open(html_path, "r", encoding="utf-8") as f:
        html = f.read()

    # 1. Strip out coi-serviceworker completely (prevents infinite reload loop in iOS WebClips)
    html = re.sub(r'<script\s+src=["\']coi-serviceworker\.min\.js["\']\s*></script>', '', html)
    html = re.sub(r'<script>\s*if\s*\(\'serviceWorker\'\s+in\s+navigator\)\s*\{\s*window\.addEventListener.*?coi-serviceworker.*?\}\s*</script>', '', html, flags=re.DOTALL)

    # 2. Fix GODOT_CONFIG: ensureCrossOriginIsolationHeaders must be FALSE (single-threaded build does not need COOP/COEP)
    html = html.replace('"ensureCrossOriginIsolationHeaders":true', '"ensureCrossOriginIsolationHeaders":false')

    # 3. Viewport with viewport-fit=cover for iPhone notch and full display
    html = re.sub(r'<meta\s+name=["\']viewport["\'][^>]*>', '<meta name="viewport" content="width=device-width, user-scalable=no, initial-scale=1.0, maximum-scale=1.0, viewport-fit=cover">', html)

    # 4. PWA and iOS WebClip Meta Tags in <head>
    pwa_head = """
		<link rel="manifest" href="manifest.webmanifest">
		<meta name="mobile-web-app-capable" content="yes">
		<meta name="apple-mobile-web-app-capable" content="yes">
		<meta name="apple-mobile-web-app-status-bar-style" content="black-translucent">
		<meta name="apple-mobile-web-app-title" content="IT Adventures">
		<meta name="theme-color" content="#0f172a">
		<link rel="apple-touch-icon" href="index.apple-touch-icon.png">

		<!-- iOS WebClip cache-cleanup script -->
		<script>
		(function() {
			try {
				sessionStorage.removeItem("coiReloadedBySelf");
				sessionStorage.removeItem("coiCoepHasFailed");
				if ('serviceWorker' in navigator) {
					navigator.serviceWorker.getRegistrations().then(function(regs) {
						for (var i = 0; i < regs.length; i++) {
							regs[i].unregister();
						}
					});
				}
			} catch(e) {}
		})();
		</script>
    """
    if 'manifest.webmanifest' not in html:
        html = html.replace('<head>', '<head>' + pwa_head)

    # 5. Replace standard Godot #status overlay with Cyber Retro Loader
    cyber_loader_dom = """
		<div id="status" style="position:fixed; top:0; left:0; width:100%; height:100%; background:radial-gradient(ellipse at center, #111827 0%, #030712 100%); display:flex; flex-direction:column; justify-content:center; align-items:center; z-index:9999; font-family:'Courier New', Courier, monospace, -apple-system, sans-serif; color:#f8fafc; visibility:visible;">
			<div style="text-align:center; max-width:440px; width:88%; padding:24px; background:rgba(15,23,42,0.96); border:2px solid #38bdf8; border-radius:14px; box-shadow:0 0 35px rgba(56,189,248,0.3);">
				<div style="font-size:22px; font-weight:900; letter-spacing:2px; color:#38bdf8; margin-bottom:4px; text-shadow:0 0 12px rgba(56,189,248,0.8);">
					⚡ IT ADVENTURES ⚡
				</div>
				<div style="font-size:11px; color:#94a3b8; margin-bottom:18px; letter-spacing:1px;">
					SOPORTE T&Eacute;CNICO RPG &bull; v1.0.4
				</div>
				
				<div style="width:100%; background:#1e293b; border:1px solid #475569; border-radius:10px; height:22px; overflow:hidden; position:relative; box-shadow:inset 0 2px 4px rgba(0,0,0,0.6);">
					<div id="retro-bar-fill" style="width:0%; height:100%; background:linear-gradient(90deg, #0284c7, #38bdf8, #818cf8); transition:width 0.15s ease-out; box-shadow:0 0 10px #38bdf8;"></div>
					<div id="retro-bar-text" style="position:absolute; top:0; left:0; width:100%; height:100%; display:flex; justify-content:center; align-items:center; font-size:11px; font-weight:bold; color:#ffffff; text-shadow:1px 1px 2px #000;">
						0%
					</div>
				</div>

				<div id="retro-status-msg" style="margin-top:14px; font-size:12px; color:#38bdf8; min-height:34px; display:flex; align-items:center; justify-content:center; text-align:center; line-height:1.4;">
					&gt; [SYS] Conectando al switch del rack y verificando cables...
				</div>

				<div id="retro-size-info" style="margin-top:8px; font-size:11px; color:#64748b;">
					Iniciando descarga optimizada...
				</div>
			</div>
			<progress id="status-progress" style="display:none;"></progress>
			<div id="status-notice" style="display:none;"></div>
		</div>
    """
    html = re.sub(r'<div\s+id=["\']status["\'].*?</div>\s*</div>', cyber_loader_dom.strip(), html, flags=re.DOTALL)

    # 6. Replace engine.startGame handler in index.html to update retro loader
    target_start = """		setStatusMode('progress');
		engine.startGame({
			'onProgress': function (current, total) {
				if (current > 0 && total > 0) {
					statusProgress.value = current;
					statusProgress.max = total;
				} else {
					statusProgress.removeAttribute('value');
					statusProgress.removeAttribute('max');
				}
			},
		}).then(() => {
			setStatusMode('hidden');
		}, displayFailureNotice);"""

    new_start_game = """		setStatusMode('progress');
		engine.startGame({
			'onProgress': function (current, total) {
				var barFill = document.getElementById('retro-bar-fill');
				var barText = document.getElementById('retro-bar-text');
				var sizeInfo = document.getElementById('retro-size-info');
				var statusMsg = document.getElementById('retro-status-msg');
				if (current > 0 && total > 0) {
					var pct = Math.min(100, Math.floor((current / total) * 100));
					if (barFill) barFill.style.width = pct + '%';
					if (barText) barText.innerText = pct + '%';
					var curMb = (current / (1024 * 1024)).toFixed(1);
					var totMb = (total / (1024 * 1024)).toFixed(1);
					if (sizeInfo) sizeInfo.innerText = curMb + ' MB / ' + totMb + ' MB';
					
					if (statusMsg) {
						if (pct < 20) {
							statusMsg.innerText = '> [SYS] Conectando al switch y verificando patchcords...';
						} else if (pct < 40) {
							statusMsg.innerText = '> [SYS] Purgando cola de impresion de la multifuncional...';
						} else if (pct < 60) {
							statusMsg.innerText = '> [SYS] Cargando USB azul milagrosa de Tonazo...';
						} else if (pct < 80) {
							statusMsg.innerText = '> [SYS] Preparando cafe para Javier y alineando toners...';
						} else if (pct < 98) {
							statusMsg.innerText = '> [SYS] Compilando shaders y politicas de seguridad...';
						} else {
							statusMsg.innerText = '> [OK] Sistema listo. Iniciando sesion de usuario...';
						}
					}
				}
			},
		}).then(() => {
			var overlay = document.getElementById('status');
			if (overlay) {
				overlay.style.transition = 'opacity 0.4s ease-out';
				overlay.style.opacity = '0';
				setTimeout(function() {
					overlay.remove();
				}, 400);
			}
			initializing = false;
		}, displayFailureNotice);"""

    if target_start in html:
        html = html.replace(target_start, new_start_game)

    # 7. HTML Install Guide Modal and helper scripts before </body>
    overlay_html = """
	<!-- Modal Guia para Guardar en Pantalla de Inicio / Escritorio -->
	<div id="install-guide-modal" style="display:none; position:fixed; top:0; left:0; width:100%; height:100%; background:rgba(0,0,0,0.85); z-index:99999; justify-content:center; align-items:center; backdrop-filter:blur(8px); padding:20px; box-sizing:border-box;">
		<div style="background:#040c28; border:3px solid #ffffff; border-radius:8px; max-width:440px; width:100%; padding:22px; color:#f8fafc; font-family:-apple-system,BlinkMacSystemFont,Segoe UI,Roboto,sans-serif; box-shadow:0 12px 36px rgba(0,0,0,0.8); position:relative;">
			<h3 style="margin-top:0; color:#fbbf24; font-size:16px; letter-spacing:1px;">
				[ ACCESO DIRECTO EN CELULAR ]
			</h3>
			<p style="font-size:13px; line-height:1.5; color:#cbd5e1; margin-bottom:14px;">
				Puedes guardar el juego como una aplicacion directa en tu pantalla de inicio:
			</p>
			<div style="background:rgba(15,23,42,0.9); border-radius:6px; padding:12px; margin-bottom:12px; font-size:12px; line-height:1.5; border-left:3px solid #38bdf8;">
				<b style="color:#38bdf8;">En iPhone / iPad (Safari):</b><br>
				1. Toca el boton <b>Compartir</b> (icono con flecha hacia arriba en la barra de Safari).<br>
				2. Elige <b>'Agregar a pantalla de inicio'</b>.<br>
				3. ¡Listo! Se abrira como app a pantalla completa.
			</div>
			<div style="background:rgba(15,23,42,0.9); border-radius:6px; padding:12px; margin-bottom:16px; font-size:12px; line-height:1.5; border-left:3px solid #4ade80;">
				<b style="color:#4ade80;">En Android (Chrome):</b><br>
				1. Toca los <b>tres puntos</b> ⋮ arriba a la derecha.<br>
				2. Selecciona <b>'Instalar aplicacion'</b> o <b>'Agregar a la pantalla principal'</b>.
			</div>
			<div style="display:flex; justify-content:flex-end;">
				<button onclick="closeInstallGuide()" style="background:#38bdf8; color:#0f172a; border:none; border-radius:6px; padding:8px 18px; font-weight:700; font-size:12px; cursor:pointer;">
					Volver al juego
				</button>
			</div>
		</div>
	</div>

	<script>
	if (window.navigator.standalone === true || window.matchMedia('(display-mode: standalone)').matches) {
		var shareBtn = document.getElementById('web-btn-share');
		if (shareBtn) shareBtn.style.display = 'none';
	}

	var deferredInstallPrompt = null;
	window.addEventListener('beforeinstallprompt', function(e) {
		e.preventDefault();
		deferredInstallPrompt = e;
		var btn = document.getElementById('web-btn-share');
		if (btn) {
			btn.innerHTML = '<span>📲</span> <span>Instalar en Tel&eacute;fono</span>';
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
    if 'install-guide-modal' not in html:
        html = html.replace('</body>', overlay_html + '\n</body>')

    with open(html_path, "w", encoding="utf-8") as f:
        f.write(html)
    print("Injected Cyber Retro Loader, PWA and iOS compatibility into build/web/index.html successfully!")

if __name__ == "__main__":
    inject_pwa_and_fullscreen()
