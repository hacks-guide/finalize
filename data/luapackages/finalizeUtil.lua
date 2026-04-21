local finalizeUtil = {}

function finalizeUtil.error(text, image, powerOff)
    if image then
        ui.show_png("9:/finalize/img/" .. image .. ".png")
    end
    if text then
        ui.echo(text)
    else
        ui.echo(" ")
    end
    if powerOff then
        sys.power_off()
    end
end

return finalizeUtil