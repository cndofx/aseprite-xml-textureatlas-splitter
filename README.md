# XML TextureAtlas Splitter

An aseprite script to unpack texture atlases with an
accompanying XML file in the following format:

```xml
<TextureAtlas imagePath="pack.png">
    <SubTexture flipX="false" flipY="false" frameHeight="128" frameWidth="128" frameX="-42" frameY="-21" height="81" name="0" width="46" x="0" y="0"/>
    <SubTexture flipX="false" flipY="false" frameHeight="128" frameWidth="128" frameX="-43" frameY="-21" height="81" name="1" width="49" x="0" y="81"/>
    <SubTexture flipX="false" flipY="false" frameHeight="128" frameWidth="128" frameX="-23" frameY="-19" height="85" name="10" width="83" x="131" y="0"/>
    <SubTexture flipX="false" flipY="false" frameHeight="128" frameWidth="128" frameX="-34" frameY="-21" height="83" name="11" width="58" x="83" y="255"/>
</TextureAtlas>
```