/*
 * AudioPlayer.hpp
 *
 *  Created on: 2018年8月1日
 *      Author: liuwanlin
 *      音频播放器
 */

#ifndef AUDIOPLAYER_HPP_
#define AUDIOPLAYER_HPP_

#include <QObject>
#include <bb/multimedia/MediaPlayer>
#include <bb/multimedia/NowPlayingConnection>
#include <bb/multimedia/MediaState>
#include "../Requester/Requester.hpp"

using namespace bb::multimedia;

class AudioPlayer : public bb::multimedia::MediaPlayer {
    Q_OBJECT
    /**
     * 格式如：http://mobile.ximalaya.com/mobile/v1/album/track?albumId=4756811&pageId=3&pageSize=20&device=android&isAsc=true
     *
     * 播放思路：
     *      1，专辑列表应用翻页模式。
     *      2，点击一个声音，传入当前页的内容，格式如上。
     *      3，在播放器列表手动上拉才会加载前面的声音。
     *      4，下拉加载后面页面的声音。
     *      5，当一个声音播放完毕，则继续下一个声音，如果没有加载到则自动加载，直到最后没有了声音才停止播放。
     *      6，当传入新的专辑信息时，替换原有的专辑。
     */
    Q_PROPERTY(QVariant albumInfo READ albumInfo WRITE setAlbumInfo NOTIFY albumInfoChanged)

    public:
        AudioPlayer();
        virtual ~AudioPlayer() {};

        QVariant albumInfo() const;

        // 获取当前播放的声音信息
        Q_INVOKABLE QVariant getCurrentTrackInfo();
        // 下一曲
        Q_INVOKABLE void next();
        // 上一曲
        Q_INVOKABLE void previous();
        // 播放
        Q_INVOKABLE void go(QString trackId);
        Q_INVOKABLE void startExitTimer(int m); // m分钟后关闭

    private:
        Requester *requester;
        NowPlayingConnection *nowPlayingConnection;
        QVariant mAlbumInfo;
        QMap<QString, QVariant> currentTrackInfo; // 当前播放的声音信息

        QMap<QString, QVariant> getTrackItemNyId(QString trackId);
        QMap<QString, QVariant> getPreNextTrackItem(int flag); // -1 上一曲 1 下一曲
        void playNextAlbum();
        void playPreAlbum();

        void go(QMap<QString, QVariant> trackItem);
        void setNpInfo(QMap<QString, QVariant> trackItem);

        static QString albumInfoApi;

        // 界面卡住的问题
        QTimer *playTimer;
        QTimer *exitTimer;
        long exitTime;
        long currentExitTime;

        void startPlayTimer();

    public slots:
        void npPlay();
        void npPause();
        void npRevoked();
        void npPrevious();
        void npNext();

        void mpMediaStateChanged(bb::multimedia::MediaState::Type mediaState);
        void mpDurationChanged(unsigned int duration);
        void mpPositionChanged(unsigned int position);
        void mpPlaybackCompleted(); // 歌曲播放完毕

        void setAlbumInfo(const QVariant albumInfo);
        void getNextAlbumFinished(QString data);
        void getNextAlbumError(QString errorMsg);

        void getPreAlbumFinished(QString data);
        void getPreAlbumError(QString errorMsg);

        void playTimerTimeout();
        void exitTimerTimeout();
    signals:
        void albumInfoChanged(); // 专辑改变
        void currentTrackChanged(QString trackId); // 播放声音，信息改变
        void albumEnd(int flag); // 专辑播放完了, -1 播放列表无上一集了 1 专辑播放完了
        void track404(); // 播放声音没找到
        void preNextTrack(int flag); // 上一集或者下一集

        void exitTimerInterval(long currentExitTime, long exitTime);
};

#endif /* AUDIOPLAYER_HPP_ */
