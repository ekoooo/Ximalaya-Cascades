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
- playPathAacv164
- playPathAacv224

##### 播放器元素
- 演播+当前播放
- 当前播放专辑页
    - 上页下页
- 时间轴
    - 可调整时间
- 上集、下集
    - 当前页面播放完毕，自动加载下集播放
    - 上集到当前页面第一个不能继续上一集
- 定时关闭
    - 声音集数
    - 时间

##### 测试地址
list: `http://mobile.ximalaya.com/mobile/v1/album/track?albumId=4756811&pageId=3&pageSize=20&device=android&isAsc=true`

item: `http://mobile.ximalaya.com/v1/track/baseInfo?device=android&trackId=28644975`

playUrl32: `http://fdfs.xmcdn.com/group24/M09/7A/9A/wKgJMFh3gWSCoMhRADeg0s5eCu8103.mp3`

playUrl64: `http://fdfs.xmcdn.com/group24/M09/7A/97/wKgJMFh3gVeRBm_IAG9BOlwcZH4917.mp3`

downloadAacUrl: `http://download.xmcdn.com/group24/M09/7A/9A/wKgJMFh3gWnDvg_xACsOftIhkuI230.m4a`

playPathAacv164: `http://audio.xmcdn.com/group24/M09/7A/B9/wKgJNVh3gVfS0u9oAHCYMSwdh6M396.m4a`

playPathAacv224: `http://audio.xmcdn.com/group24/M09/7A/9A/wKgJMFh3gWnDvg_xACsOftIhkuI230.m4a`
