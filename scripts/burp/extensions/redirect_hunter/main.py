from burp import IBurpExtender, IHttpListener, ITab, IScanIssue
from java.io import PrintWriter
from javax.swing import (JPanel, JLabel, JTextField, JButton, BoxLayout, JScrollPane,
                         JTextArea, JCheckBox, SwingConstants)
from java.awt import BorderLayout, Dimension
from java.net import URL
from urllib import quote
import threading
import time

# (keep all your import statements unchanged)

class BurpExtender(IBurpExtender, IHttpListener, ITab):

    def registerExtenderCallbacks(self, callbacks):
        self._callbacks = callbacks
        self._helpers = callbacks.getHelpers()
        self._stdout = PrintWriter(callbacks.getStdout(), True)
        self._stderr = PrintWriter(callbacks.getStderr(), True)
        self._callbacks.setExtensionName("Open Redirect Hunter")

        # Load saved settings or use defaults
        self.payloads = self.load_setting("payloads", [
            "//evil.com", "///evil.com", "https://evil.com", "http://evil.com",
            "\\\\evil.com\\@good.com", "/\\evil.com/%2f..", "/\\evil.com/%2e%2e",
            "https://evil.com#@target", "https://evil.com%2f%2e%2e"
        ])
        self.keywords = self.load_setting("keywords", ["url", "redirect", "next", "target"])
        self.delay = float(self._callbacks.loadExtensionSetting("delay") or "2.0")
        self.extension_enabled = (self._callbacks.loadExtensionSetting("enabled") != "false")  # default True

        self.last_request_time = 0
        self.lock = threading.Lock()
        self.max_threads = 5
        self.active_threads = []
        self.scanned_requests = set()

        self.init_gui()
        callbacks.addSuiteTab(self)
        callbacks.registerHttpListener(self)
        self.update_status("Extension loaded and ready.")

    def load_setting(self, key, default):
        saved = self._callbacks.loadExtensionSetting(key)
        if saved:
            if isinstance(default, list):
                return [item.strip() for item in saved.strip().split('\n') if item.strip()]
            return saved
        return default

    def save_settings(self, event):
        try:
            self.payloads = [p.strip() for p in self.payload_area.getText().splitlines() if p.strip()]
            self.keywords = [k.strip().lower() for k in self.keyword_field.getText().split(',') if k.strip()]
            self.delay = float(self.rate_field.getText().strip())
            self.extension_enabled = self.toggle_checkbox.isSelected()

            # [Persistent Setting]
            self._callbacks.saveExtensionSetting("payloads", "\n".join(self.payloads))
            self._callbacks.saveExtensionSetting("keywords", ",".join(self.keywords))
            self._callbacks.saveExtensionSetting("delay", str(self.delay))
            self._callbacks.saveExtensionSetting("enabled", "true" if self.extension_enabled else "false")

            self.update_status("Settings saved and persisted.")
        except Exception as e:
            self._stderr.println("[!] Error updating settings: %s" % str(e))
            self.update_status("Error saving settings.")

    def toggle_extension(self, event):
        self.extension_enabled = self.toggle_checkbox.isSelected()
        self._callbacks.saveExtensionSetting("enabled", "true" if self.extension_enabled else "false")  # [Persistent Setting]
        status = "enabled" if self.extension_enabled else "disabled"
        self.update_status("Extension is now %s." % status)

    def init_gui(self):
        self.panel = JPanel(BorderLayout())
        settings_panel = JPanel()
        settings_panel.setLayout(BoxLayout(settings_panel, BoxLayout.Y_AXIS))

        settings_panel.add(JLabel("Payloads (one per line):"))
        self.payload_area = JTextArea("\n".join(self.payloads), 8, 50)
        scroll_payload = JScrollPane(self.payload_area)
        scroll_payload.setPreferredSize(Dimension(500, 100))
        settings_panel.add(scroll_payload)

        settings_panel.add(JLabel("Keywords to watch in query string (comma-separated):"))
        self.keyword_field = JTextField(", ".join(self.keywords), 50)
        settings_panel.add(self.keyword_field)

        settings_panel.add(JLabel("Rate Limit (seconds between scans):"))
        self.rate_field = JTextField(str(self.delay), 5)
        settings_panel.add(self.rate_field)

        self.toggle_checkbox = JCheckBox("Enable Extension", self.extension_enabled)
        self.toggle_checkbox.addActionListener(self.toggle_extension)
        settings_panel.add(self.toggle_checkbox)

        self.save_button = JButton("Save Settings", actionPerformed=self.save_settings)
        settings_panel.add(self.save_button)

        self.status_label = JLabel("Status: Ready", SwingConstants.LEFT)
        self.panel.add(settings_panel, BorderLayout.NORTH)
        self.panel.add(self.status_label, BorderLayout.SOUTH)


    def getTabCaption(self):
        return "Open Redirect Hunter"

    def getUiComponent(self):
        return self.panel

    def update_status(self, message):
        self.status_label.setText("Status: " + message)
        self._stdout.println("[*] " + message)

    def processHttpMessage(self, toolFlag, messageIsRequest, messageInfo):
        if not self.extension_enabled or not messageIsRequest:
            return

        try:
            request_info = self._helpers.analyzeRequest(messageInfo)
            url = request_info.getUrl()
            method = request_info.getMethod()
            if method != "GET":
                return

            if not self._callbacks.isInScope(url):
                return

            query = url.getQuery()
            if not query:
                return

            scanned_any = False

            for param in query.split('&'):
                key, _, val = param.partition('=')
                key = key.strip()
                if any(word in key.lower() for word in self.keywords):
                    key_id = (url.getPath(), key.lower())
                    if key_id not in self.scanned_requests:
                        self.scanned_requests.add(key_id)
                        if not scanned_any:
                            self.start_scan_thread(url, messageInfo)
                            scanned_any = True
        except Exception as e:
            self._stderr.println("[!] Error in processing request: %s" % str(e))


    def start_scan_thread(self, url, messageInfo):
        with self.lock:
            if len(self.active_threads) >= self.max_threads:
                return

            def runner():
                try:
                    self.scan_with_rate_limit(url, messageInfo)
                except Exception as e:
                    self._stderr.println("[!] Thread error: %s" % str(e))
                finally:
                    with self.lock:
                        self.active_threads.remove(thread)

            thread = threading.Thread(target=runner)
            self.active_threads.append(thread)
            thread.start()

    def scan_with_rate_limit(self, url, messageInfo):
        with self.lock:
            now = time.time()
            wait = self.delay - (now - self.last_request_time)
            if wait > 0:
                time.sleep(wait)
            self.last_request_time = time.time()
        self.scan_for_redirects(url, messageInfo)

    def scan_for_redirects(self, base_url, messageInfo):
        try:
            parsed = self._helpers.analyzeRequest(messageInfo)
            headers = list(parsed.getHeaders())
            orig_url = base_url.toString()
            query = base_url.getQuery()
            found = False
            attempt = 0

            self.update_status("Scanning: %s" % base_url)

            # Parse query params into a dict for safe replacement
            params = {}
            for param in query.split('&'):
                key, sep, val = param.partition('=')
                params[key] = val

            for payload in self.payloads:
                for key in params:
                    if any(word in key.lower() for word in self.keywords):
                        # Replace param value safely
                        new_params = params.copy()
                        new_params[key] = quote(payload)
                        new_query = "&".join("%s=%s" % (k, v) for k, v in new_params.items())

                        # Rebuild URL with new query
                        url_base = orig_url.split('?')[0]
                        new_url_str = url_base + "?" + new_query
                        request = self._helpers.buildHttpRequest(URL(new_url_str))
                        resp = self._callbacks.makeHttpRequest(messageInfo.getHttpService(), request)
                        analyzed_resp = self._helpers.analyzeResponse(resp.getResponse())

                        for hdr in analyzed_resp.getHeaders():
                            if hdr.lower().startswith("location") and payload in hdr:
                                issue = CustomScanIssue(
                                    messageInfo.getHttpService(),
                                    URL(new_url_str),
                                    [messageInfo],
                                    "Open Redirect",
                                    "The application redirects to: {}".format(payload),
                                    "High"
                                )
                                self._callbacks.addScanIssue(issue)
                                self._stdout.println("[+] Open Redirect found: %s -> %s" % (base_url, payload))
                                found = True
                                break
                        attempt += 1
                        if found and attempt >= 3:
                            self.update_status("Open Redirect found, stopping scan early.")
                            return
            if not found:
                self.update_status("Finished scan: no open redirect found.")
        except Exception as e:
            self._stderr.println("[!] Scan error: %s" % str(e))
            self.update_status("Error during scan.")

class CustomScanIssue(IScanIssue):
    def __init__(self, httpService, url, httpMessages, name, detail, severity):
        self._httpService = httpService
        self._url = url
        self._httpMessages = httpMessages
        self._name = name
        self._detail = detail
        self._severity = severity

    def getUrl(self):
        return self._url

    def getIssueName(self):
        return self._name

    def getIssueType(self):
        return 0x08000000  # Custom issue ID

    def getSeverity(self):
        return self._severity

    def getConfidence(self):
        return "Certain"

    def getIssueBackground(self):
        return None

    def getRemediationBackground(self):
        return None

    def getIssueDetail(self):
        return self._detail

    def getRemediationDetail(self):
        return None

    def getHttpMessages(self):
        return self._httpMessages

    def getHttpService(self):
        return self._httpService
