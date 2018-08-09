/*
 * AudioPlayer.cpp
 *
 *  Created on: 2018年8月1日
 *      Author: liuwanlin
 */

#include "AudioPlayer.hpp"
#include "../Misc/Misc.hpp"

#include <QObject>
#include <bb/multimedia/MediaPlayer>
#include <bb/multimedia/NowPlayingConnection>
#include <bb/multimedia/OverlayStyle>
#include <bb/multimedia/MediaState>
#include <bb/data/JsonDataAccess>
#include "../Misc/Misc.hpp"
#include "../Requester/Requester.hpp"

using namespace bb::multimedia;
using namespace bb::data;

QString AudioPlayer::albumInfoApi = "http://mobile.ximalaya.com/mobile/v1/album/track?albumId=%1&pageId=%2&pageSize=20&isAsc=%3";

AudioPlayer::AudioPlayer() : bb::multimedia::MediaPlayer() {
    this->playTimer = new QTimer();
    this->exitTimer = new QTimer();

    this->exitTime = 0;
    this->currentExitTime = 0;
    this->requester = NULL;

    connect(playTimer, SIGNAL(timeout()), this, SLOT(playTimerTimeout()));
    connect(exitTimer, SIGNAL(timeout()), this, SLOT(exitTimerTimeout()));

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
    connect(this, SIGNAL(playbackCompleted()), this, SLOT(mpPlaybackCompleted()));
}

void AudioPlayer::mpMediaStateChanged(bb::multimedia::MediaState::Type mediaState) {
    nowPlayingConnection->setMediaState(mediaState);
    if(mediaState == MediaState::Started) {
        nowPlayingConnection->acquire();
    }else if(mediaState == MediaState::Stopped) {
        nowPlayingConnection->revoke();
    }
}
void AudioPlayer::mpDurationChanged(unsigned int duration) {
    nowPlayingConnection->setDuration(duration);
}
void AudioPlayer::mpPositionChanged(unsigned int position) {
    nowPlayingConnection->setPosition(position);
}
void AudioPlayer::mpPlaybackCompleted() {
    this->next();
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

// 根据声音ID，获取信息
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

    bool isSearched = false;
    int i = 0, nextIndex, preIndex;

    for(i = 0; i < list.length(); i++) {
        item = list.at(i).toMap();
        if(item["trackId"].toString() == this->currentTrackInfo["trackId"].toString()) {
            nextIndex = i + 1;
            preIndex = i - 1;
            isSearched = true;
            break;
        }
    }

    if(isSearched) {
        if(flag == 1 && nextIndex < list.length()) {
            rt = list.at(nextIndex).toMap();
        }
        if(flag == -1 && preIndex >= 0) {
            rt = list.at(preIndex).toMap();
        }
    }

    return rt;
}

// 获取下一页专辑信息
void AudioPlayer::playNextAlbum() {
    QMap<QString, QVariant> info = this->mAlbumInfo.toMap();
    QMap<QString, QVariant> data = info["data"].toMap();
    QList<QVariant> list = data["list"].toList();
    int currentPage = data["pageId"].toInt();

    if(currentPage < data["maxPageId"].toInt()) {
        QString albumId = list.at(0).toMap()["albumId"].toString();
        QString isAsc = Misc::getConfig("isAsc::albumId::", "1") == "1" ? "true" : "false"; // 排序，缓存中取。
        QString url = AudioPlayer::albumInfoApi.arg(albumId).arg(currentPage + 1).arg(isAsc);

        requester = new Requester();
        requester->send(url);
        connect(requester, SIGNAL(finished(QString)), this, SLOT(getNextAlbumFinished(QString)));
        connect(requester, SIGNAL(error(QString)), this, SLOT(getNextAlbumError(QString)));
    }else {
        emit albumEnd(1);
    }
}
void AudioPlayer::getNextAlbumFinished(QString data) {
    JsonDataAccess jda;
    QVariant albumInfo = jda.loadFromBuffer(data.toUtf8());

    QMap<QString, QVariant> info = albumInfo.toMap();
    QMap<QString, QVariant> dataMap = info["data"].toMap();
    QList<QVariant> list = dataMap["list"].toList();

    // 判断下一页是不是付费声音
    QMap<QString, QVariant> itemInfo = list.at(0).toMap();

    if(itemInfo["isPaid"].toBool() && !itemInfo["isFree"].toBool()) {
        qDebug() << "AudioPlayer::getNextAlbumFinished isFree" << itemInfo["isFree"].toBool();
        emit track404();
        return;
    }

    this->setAlbumInfo(albumInfo);
    // 播放第一首
    this->go(list.at(0).toMap());
}
void AudioPlayer::getNextAlbumError(QString errorMsg) {
    qDebug() << "AudioPlayer::getNextAlbumError errorMsg:" << errorMsg;
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
        /**
         * 播放源和大小
         * playUrl64 e.g. 5.26mb // 默认
         * playUrl32 e.g. 2.63mb
         * playPathAacv224 e.g. 2.04mb
         * playPathAacv164 e.g. 5.33mb
         *
         * playPathHq 高质量，有的没有
         */
        QString audioPlayerSourceType = Misc::getConfig("audioPlayerSourceType", "playUrl64");
        QString playUrl;

        if(audioPlayerSourceType == "playPathHq" && trackItem["playPathHq"].toString() == "") { // 如果没有高质量声音，那就设置为 playUrl64
            audioPlayerSourceType = "playUrl64";
        }

        playUrl = trackItem[audioPlayerSourceType].toString();

        qDebug() << "AudioPlayer::go source type:" << audioPlayerSourceType << ", play url:" << playUrl;

        if(trackItem["isPaid"].toBool() && !trackItem["isFree"].toBool()) { // 付费声音
            qDebug() << "AudioPlayer::go isFree" << trackItem["isFree"].toBool();
            emit track404();
            return;
        }

        this->setSourceUrl(playUrl);
        this->setNpInfo(trackItem);
        // this->setVolume(1);
        this->startPlayTimer();

        // 保存当前信息
        this->currentTrackInfo = trackItem;
        // 保存标志到 Settings 中
        Misc::setConfig("currentPlayTrackId", trackItem["trackId"].toString());
        // 返回信息，用于更新界面
        emit currentTrackChanged(trackItem["trackId"].toString());
    }else {
        qDebug() << "AudioPlayer::go trackItem isEmpty";
        emit track404();
    }
}

// 下一个
void AudioPlayer::next() {
    // 获取当前播放的信息
    QMap<QString, QVariant> trackItem = this->getPreNextTrackItem(1);
    if(trackItem.isEmpty()) {
        // 没有下一曲了，加载下一页的内容
        this->playNextAlbum();
    }else {
        emit preNextTrack(1);

        this->go(trackItem);
    }
}

// 上一个
void AudioPlayer::previous() {
    // 获取当前播放的信息
    QMap<QString, QVariant> trackItem = this->getPreNextTrackItem(-1);
    if(trackItem.isEmpty()) {
        // 没有上一曲了，或者为收费声音
        emit albumEnd(-1);
    }else {
        emit preNextTrack(-1);

        this->go(trackItem);
    }
}

void AudioPlayer::startPlayTimer() {
    this->playTimer->stop();
    this->playTimer->setInterval(300);
    this->playTimer->start();
    qDebug() << "AudioPlayer::startPlayTimer execute this->playTimer->start() ~~~~~";
}
void AudioPlayer::playTimerTimeout() {
    this->playTimer->stop();
    this->play();
}

void AudioPlayer::startExitTimer(int m) {
    if(m == -1) {
        this->exitTimer->stop();
        emit exitTimerInterval(0, 0);
        return;
    }

    this->exitTime = m * 1000 * 60;
    this->currentExitTime = 0;

    this->exitTimer->stop();
    this->exitTimer->setInterval(1000);
    this->exitTimer->start();

    emit exitTimerInterval(this->currentExitTime, this->exitTime);
}
void AudioPlayer::exitTimerTimeout() {
    this->currentExitTime = this->currentExitTime + 1000;

    if(this->currentExitTime >= this->exitTime) {
        this->exitTimer->stop();
        emit exitTimerInterval(0, 0);
        // 关闭应用
        Misc::exit();
    }else {
        emit exitTimerInterval(this->currentExitTime, this->exitTime);
    }
}
