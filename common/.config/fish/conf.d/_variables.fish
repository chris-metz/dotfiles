if command -q nvim
    set -gx EDITOR (command -s nvim)
else
    set -gx EDITOR vim
end

# Kimi-Konto liegt auf kimi.ai (internationale Region), pi nimmt sonst auth.kimi.com.
# Gilt für /login und für das Token-Refresh. Übergangslösung, bis pi kimi.ai
# selbst kann: https://github.com/earendil-works/pi/issues/9819
set -gx KIMI_CODE_OAUTH_HOST https://auth.kimi.ai
