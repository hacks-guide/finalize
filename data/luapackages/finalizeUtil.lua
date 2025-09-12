local finalizeUtil = {}

function finalizeUtil.error(text, image, powerOff)
    ui.show_png("9:/finalize/img/" .. image .. ".png")
    ui.echo(text)
    if powerOff then
        sys.power_off()
    end
end

return finalizeUtil