--original code by wesstag https://steamcommunity.com/sharedfiles/filedetails/?id=3014388607
require("LifeBoatAPI.Maths.LBVec")
---@param gpsX number Radar Position X P[1]
---@param gpsY number Radar Position Y(height) P[2]
---@param gpsZ number Radar Position Z P[3]
---@param x number Euler rotation X P[4]
---@param y number Euler rotation Y P[5]
---@param z number Euler rotation Z P[6]
---@param h1 number Radar target azimuth[2]
---@param v1 number Radar target elevation[3]
---@param dist number Radar target distance[1]
function calculateXYZ(gpsX, gpsY, gpsZ, x, y, z, h1, v1, dist)
    function rotate3d(vec, pitch, roll, yaw)
        cosa, sina, cosb, sinb, cosc, sinc = cos(yaw), sin(yaw), cos(pitch), sin(pitch), cos(roll), sin(roll)
        Axx, Axy, Axz = cosa * cosb, cosa * sinb * sinc - sina * cosc, cosa * sinb * cosc + sina * sinc
        Ayx, Ayy, Ayz = sina * cosb, sina * sinb * sinc + cosa * cosc, sina * sinb * cosc - cosa * sinc
        Azx, Azy, Azz = -sinb, cosb * sinc, cosb * cosc
        return {
            x = Axx * vec.x + Axy * vec.y + Axz * vec.z,
            y = Ayx * vec.x + Ayy * vec.y + Ayz * vec.z,
            z = Azx * vec.x + Azy * vec.y + Azz * vec.z
        }
    end

    cos, sin, atan, sqrt, pi2 = math.cos, math.sin, math.atan, math.sqrt, 2 * math.pi

    cx, sx, cy, sy, cz, sz = cos(x), sin(x), cos(y), sin(y), cos(z), sin(z)
    m00, m01, m02 = cy * cz, -cx * sz + sx * sy * cz, sx * sz + cx * sy * cz
    m10, m11, m12 = cy * sz, cx * cz + sx * sy * sz, -sx * cz + cx * sy * sz
    m20, m21, m22 = -sy, sx * cy, cx * cy

    local tilt_x, tilt_y, tilt_z, compass_z = atan(m10, sqrt(m00 * m00 + m20 * m20)) / pi2, atan(m11, sqrt(m10 * m10 + m12 * m12)) / pi2, atan(m12, sqrt(m11 * m11 + m10 * m10)) / pi2,
    atan(m02, m22) / -pi2

    local h1, v1 = -h1 * pi2, v1 * pi2
    local yaw, pitch, roll = compass_z * -pi2, tilt_z * pi2, -tilt_x * pi2
    local globalRoll = atan(sin(roll), sin(tilt_y * pi2))

    Vec1 = {x = 0, y = dist, z = 0}
    Vec2 = rotate3d(Vec1, 0, v1, h1)
    Vec3 = rotate3d(Vec2, globalRoll, 0, 0)
    Vec4 = rotate3d(Vec3, 0, pitch, -yaw)

    return LifeBoatAPI.LBVec:new(Vec4.x + gpsX, Vec4.y + gpsY, Vec4.z + gpsZ)
end