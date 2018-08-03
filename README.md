# 喜马拉雅 Cascades 版
> 正在整理思路中...

##### 播放
- 播放器列表按专辑播放。
- 不能对播放器列表中的声音进行排序等操作。
- 当播放当前 page 最后一首时，自动加载 next page 音频，直到播放完毕。
- 当播放其他专辑时，之前播放列表清空。
- 记录播放历史。

##### 播放源（是否提供选择，经过测试有的地址加载比较慢）
- playUrl32
- playUrl64
- downloadAacUrl
- playPathAacv164
- playPathAacv224

##### 播放器元素
- 播放名称
- 封面
- 播放列表
    - 播放顺序
    - 标记当前
    - 下载音频
- 定时关闭
     - 按时间
     - 按集数
- 操作
    - 可滑动调整之间
    - 上首
    - 下首
    - 播放速度

##### 测试地址
`http://mobile.ximalaya.com/mobile/v1/album/track?albumId=4756811&pageId=3&pageSize=20&device=android&isAsc=true`
`http://mobile.ximalaya.com/v1/track/baseInfo?device=android&trackId=28644975`
playUrl32: `http://fdfs.xmcdn.com/group24/M09/7A/9A/wKgJMFh3gWSCoMhRADeg0s5eCu8103.mp3`
playUrl64: `http://fdfs.xmcdn.com/group24/M09/7A/97/wKgJMFh3gVeRBm_IAG9BOlwcZH4917.mp3`
downloadAacUrl: `http://download.xmcdn.com/group24/M09/7A/9A/wKgJMFh3gWnDvg_xACsOftIhkuI230.m4a`
playPathAacv164: `http://audio.xmcdn.com/group24/M09/7A/B9/wKgJNVh3gVfS0u9oAHCYMSwdh6M396.m4a`
playPathAacv224: `http://audio.xmcdn.com/group24/M09/7A/9A/wKgJMFh3gWnDvg_xACsOftIhkuI230.m4a`
