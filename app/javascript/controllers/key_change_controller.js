import { Controller } from "@hotwired/stimulus"

// TODO: こちらのconstはクラスの中に入れるべきかどうか確認すること。
const NOTES = ['C', 'C♯', 'D', 'D♯', 'E', 'F', 'F♯', 'G', 'G♯', 'A', 'A♯', 'B'];

// 順番が大切で、長い文字列から始める。
const CHORD_TYPES = [
  "maj13",
  "maj7",
  "maj9",
  "maj",
  "min",
  "m13",
  "m9",
  "m7",
  "m",
  "7sus",
  "9sus",
  "sus",
  "add2",
  "add9",
  "dim7",
  "dim",
  "aug",
  "5",
  "6",
  "7",
  "11",
  "13"
];

// 歌の行はコードの行か歌詞の行かをするための正規表現。
const whiteSpaceRegexp = /^\s+$/;
const chordBaseRegexp = /^[C|D|E|F|G|A|B][♯|♭]?/;
const fullChordRegexp = new RegExp(`^[C|D|E|F|G|A|B][♯|♭]?[${CHORD_TYPES.join("|")}]?`); // TODO: 文字列補間
const chordAdditionRegexp = new RegExp(`[${CHORD_TYPES.join("|")}]$`)

export default class extends Controller {
  static targets = ["keySelect", "songBodyContainer"];
  static values = {
    originalKey: String,
    originalSongBody: String
  };

  // TODO: 「#」と「b」が書いているところを「♯」と「♭」に置き換える。
  connect() {}

  changeKey() {
    let newKey = this.keySelectTarget.value;
    let step = this.calculateStep(this.originalKeyValue, newKey);
    let newSongBody = this.songBodyWithNewChords(step);
    this.songBodyContainerTarget.firstElementChild.innerHTML = newSongBody;
  }

  // 元のキーとの差分(音程)を計算する。
  // 負の値だったら音程が下がっとこと、正の値だったら音程が上がったことを表す整数を返します。
  calculateStep(originalKey, newKey) {
    let originalKeyIndex = NOTES.indexOf(originalKey) + 1;
    let newKeyIndex = NOTES.indexOf(newKey) + 1;
    return newKeyIndex - originalKeyIndex;
  }

  songBodyWithNewChords(step) {
    let songBody = this.originalSongBodyValue;
    let songBodyLines = songBody.split('\n');
    let newSongBodyLines = [];

    // 行ごとを処理する。
    for(var i = 0; i < songBodyLines.length; i++) {
      let lineParts = this.lineParts(songBodyLines[i]);

      // 改行の時はlinePartsは空なので、空の文字列を入れる。
      if(lineParts.length == 0) { lineParts = [""]; }

      if(this.isLineOfChords(lineParts)) {
        let newChordLineParts = [];

        // コードと空白両方はあるので、コードなのか検知してから適切な処理を行う。
        for(var j = 0; j < lineParts.length; j++) {
          if(this.isChord(lineParts[j])) {
            // 分数コードの可能性もあるので、それぞれの要素を配列に格納し、ループで一個ずつ処理します。
            let chords = lineParts[j].split("/");

            for(var k = 0; k < chords.length; k++) {
              let [chordBase, chordType] =  this.chordDetails(chords[k]);
              let newChordBase = this.adjustChordByStep(chordBase, step);
              if (chordType) { newChordBase += chordType; }
              chords[k] = newChordBase;
            }
            newChordLineParts.push(chords.join("/"));
          } else {
            // 空白の場合はそのまま格納する。
            newChordLineParts.push(lineParts[j]);
          }
        }
        newSongBodyLines.push(newChordLineParts.join(""));
      } else {
        // 行は歌詞や改行などの場合は、そのまま格納する。
        newSongBodyLines.push(songBodyLines[i]);
      }
    }

    // 処理終了
    return newSongBodyLines.join("\n");
  }

  // コードのある行であるかどうかチェックして真偽値を返す。
  isLineOfChords(lineParts){
    let result = true;
    for(var i = 0; i < lineParts.length; i++) {
      if (!(fullChordRegexp.test(lineParts[i]) || whiteSpaceRegexp.test(lineParts[i]) || lineParts[i] == '')) {
        result = false;
      } 
      
      // 改行の時もfalseを返す。
      if (lineParts.length == 1 && lineParts[i] == '') {
        result = false
      }
    }
    return result;
  }

  lineParts(line) {
    return line.split(/(\s+)/g);
  }

  adjustChordByStep(chord, step) {
    let currentChordIndex = NOTES.indexOf(chord);
    let newChordIndex = (currentChordIndex + step);

    // 配列からはみ出たら、円みたいな感じで反対側から続く。
    if (newChordIndex < 0) {
      newChordIndex += 12;
    } else if (newChordIndex > 12) {
      newChordIndex -= 12;
    }
    return NOTES[newChordIndex];
  }

  // 引数は"G♯maj7"の場合は["G♯", "maj7"]を返す。
  chordDetails(chord) {
    if(chordAdditionRegexp.test(chord)) {
      let chordBase = chordBaseRegexp.exec(chord).pop();
      let chordType = chord.replace(chordBaseRegexp, "");
      return [chordBase, chordType];
    } else {
      return [chord, null]; // TODO: [chord]だけでいいかな
    }
  }

  // TODO: リファクタリング。
  isChord(str) {
    if(whiteSpaceRegexp.test(str)) {
      return false;
    } else if (fullChordRegexp.test(str)) {
      return true;
    } else {
      return false;
    }
  }
}
