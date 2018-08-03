/*
 * AudioPlayer.cpp
 *
 *  Created on: 2018年8月1日
 *      Author: liuwanlin
 */

#include "AudioPlayer.hpp"

#include <QObject>
#include <bb/multimedia/MediaPlayer>
#include <bb/multimedia/NowPlayingConnection>
#include <bb/multimedia/OverlayStyle>
#include <bb/multimedia/MediaState>
#include "../Misc/Misc.hpp"

using namespace bb::multimedia;

AudioPlayer::AudioPlayer() : bb::multimedia::MediaPlayer() {
    nowPlayingConnection = new NowPlayingConnection(this);
    nowPlayingConnection->setOverlayStyle(OverlayStyle::Fancy);

    connect(nowPlayingConnection, SIGNAL(play()), this, SLOT(npPlay()));
    connect(nowPlayingConnection, SIGNAL(pause()), this, SLOT(npPause()));
    connect(nowPlayingConnection, SIGNAL(revoked()), this, SLOT(npRevoked()));
    connect(nowPlayingConnection, SIGNAL(previous()), this, SLOT(npPrevious()));
    connect(nowPlayingConnection, SIGNAL(next()), this, SLOT(npNext()));

    connect(this, SIGNAL(mediaStateChanged(bb::multimedia::MediaState::Type)), this, SLOT(mpMediaStateChanged(bb::multimedia::MediaState::Type)));
    connect(this, SIGNAL(durationChanged(unsigned int)), this, SLOT(mpDurationChanged(unsigned int)));
    connect(this, SIGNAL(positionChanged(unsigned int)), this, SLOT(mpPositionChanged(unsigned int)));
}

void AudioPlayer::mpMediaStateChanged(bb::multimedia::MediaState::Type mediaState) {
    nowPlayingConnection->setMediaState(mediaState);
    if(mediaState == MediaState::Started) {
        nowPlayingConnection->acquire();
    }else if(mediaState == MediaState::Stopped) {
        nowPlayingConnection->revoke();
    }
    emit myMediaStateChanged(mediaState);
}
void AudioPlayer::mpDurationChanged(unsigned int duration) {
    nowPlayingConnection->setDuration(duration);
    emit myDurationChanged(duration);
}
void AudioPlayer::mpPositionChanged(unsigned int position) {
    nowPlayingConnection->setPosition(position);
    emit myPositionChanged(position);
    // 到了最后一秒就下一曲
    if(this->duration() > 0 && this->duration() - position < 1000) {
        this->next();
    }
}

void AudioPlayer::npPlay() {
    this->play();
}
void AudioPlayer::npPause() {
    this->pause();
}
void AudioPlayer::npRevoked() {
    this->stop();
}
void AudioPlayer::npPrevious() {
    this->previous();
}
void AudioPlayer::npNext() {
    this->next();
}

QVariant AudioPlayer::albumInfo() const {
    return this->mAlbumInfo;
}

void AudioPlayer::setAlbumInfo(const QVariant albumInfo) {
    this->mAlbumInfo = albumInfo;
    emit albumInfoChanged();
}

QMap<QString, QVariant> AudioPlayer::getTrackItemNyId(QString trackId) {
    QMap<QString, QVariant> rt;
    QMap<QString, QVariant> item;
    // 获取地址
    QMap<QString, QVariant> info = this->mAlbumInfo.toMap();
    QMap<QString, QVariant> data = info["data"].toMap();
    QList<QVariant> list = data["list"].toList();

    int i = 0;
    for(i = 0; i < list.length(); i++) {
        item = list.at(i).toMap();
        if(item["trackId"].toString() == trackId) {
            rt = item;
            break;
        }
    }

    return rt;
}

// 获取下一曲的信息，如果没有下一曲，则返回空
QMap<QString, QVariant> AudioPlayer::getPreNextTrackItem(int flag) {
    QMap<QString, QVariant> rt;
    QMap<QString, QVariant> item;

    QMap<QString, QVariant> info = this->mAlbumInfo.toMap();
    QMap<QString, QVariant> data = info["data"].toMap();
    QList<QVariant> list = data["list"].toList();

    int i = 0, nextIndex, preIndex;
    for(i = 0; i < list.length(); i++) {
        item = list.at(i).toMap();
        if(item["trackId"].toString() == this->currentTrackInfo["trackId"].toString()) {
            nextIndex = i + 1;
            preIndex = i - 1;
            break;
        }
    }

    if(flag == 1 && nextIndex < list.length()) {
        rt = list.at(nextIndex).toMap();
    }
    if(flag == -1 && preIndex >= 0) {
        rt = list.at(preIndex).toMap();
    }

    return rt;
}

// 设置 metaData 和 icon
void AudioPlayer::setNpInfo(QMap<QString, QVariant> trackItem) {
    QVariantMap metaData;

    metaData.insert("artist", trackItem["nickname"].toString());
    metaData.insert("title", trackItem["title"].toString());

    nowPlayingConnection->setMetaData(metaData);
    nowPlayingConnection->setIconUrl(QUrl("asset:///images/ting_np_icon.png"));
}

// 当前播放声音的信息
QVariant AudioPlayer::getCurrentTrackInfo() {
    return this->currentTrackInfo;
}

// 播放声音
void AudioPlayer::go(QString trackId) {
    this->go(this->getTrackItemNyId(trackId));
}
void AudioPlayer::go(QMap<QString, QVariant> trackItem) {
    if(!trackItem.isEmpty()) {
        qDebug() << "play:" << trackItem["playUrl64"].toString();

        this->setSourceUrl(trackItem["playUrl64"].toString());
        this->setNpInfo(trackItem);
        this->setVolume(1);
        this->play();

        // 保存当前信息
        this->currentTrackInfo = trackItem;
        // 保存标志到 Settings 中
        Misc::setConfig("currentPlayTrackId", trackItem["trackId"].toString());
        // 返回信息，用于更新界面
        emit currentTrackChanged();
    }else {
        qDebug() << "播放失败，trackItem isEmpty";
    }
}

// 下一个
void AudioPlayer::next() {
    // 获取当前播放的信息
    QMap<QString, QVariant> trackItem = this->getPreNextTrackItem(1);
    if(trackItem.isEmpty()) {
        // 没有下一曲了，加载下一页的内容

    }else {
        // emit previousOrNext(1);
        // 播放下一曲
        this->go(trackItem);
    }
}

// 上一个
void AudioPlayer::previous() {
    // 获取当前播放的信息
    QMap<QString, QVariant> trackItem = this->getPreNextTrackItem(-1);
    if(trackItem.isEmpty()) {
        // 没有下一曲了，加载下一页的内容

    }else {
        // emit previousOrNext(1);
        // 播放下一曲
        this->go(trackItem);
    }
}
