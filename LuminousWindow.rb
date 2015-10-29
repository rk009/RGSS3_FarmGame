#==============================================================================
# ■ RK::LuminousWindow
#------------------------------------------------------------------------------
# 　窓の部分のみを色調の上に表示させることで夜の明かりを実現します。
#==============================================================================
module RK
  module LuminousWindow
    
    # 昼用Tilemap => 夜用Tilemap
    # 昼用Tilemapに夜用が被るため窓以外の不要なマップチップは置かないように
    TilePair = {
    5 => 6,
    1 => 10,
    2 => 10,
    3 => 10,
    4 => 10
    }
    
    # 発光タイルを置く条件(夜かどうか)
    def self.luminous?
      $game_variables[2] >= 19 || $game_variables[2] < 4
    end
    
  end
end

#==============================================================================
# ■ Game_Map
#------------------------------------------------------------------------------
# 　タイルセット取得のメソッドを追加
#==============================================================================
class Game_Map
  #--------------------------------------------------------------------------
  # ● 発光窓タイルセットの取得
  #--------------------------------------------------------------------------
  def rk_tileset
    $data_tilesets[RK::LuminousWindow::TilePair[@tileset_id]]
  end
end

#==============================================================================
# ■ Spriteset_Map
#------------------------------------------------------------------------------
# 　マップ画面のスプライトやタイルマップなどをまとめたクラスです。
#==============================================================================
class Spriteset_Map
  #--------------------------------------------------------------------------
  # ● ビューポートの作成
  #--------------------------------------------------------------------------
  alias rk_spriteset_map_create_viewports create_viewports
  def create_viewports
    rk_spriteset_map_create_viewports
    @viewport_top = Viewport.new
  end
  #--------------------------------------------------------------------------
  # ● タイルマップの作成
  #--------------------------------------------------------------------------
  alias rk_spriteset_map_create_tilemap create_tilemap
  def create_tilemap
    rk_spriteset_map_create_tilemap
    @top_tilemap = Tilemap.new(@viewport_top)
    @top_tilemap.map_data = $game_map.data
    rk_load_tileset
  end
  #--------------------------------------------------------------------------
  # ● タイルセットのロード
  #--------------------------------------------------------------------------
  def rk_load_tileset
    @top_tileset = $game_map.rk_tileset
    if @top_tileset && RK::LuminousWindow::luminous?
      @top_tileset.tileset_names.each_with_index do |name, i|
        @top_tilemap.bitmaps[i] = Cache.tileset(name)
      end
      @top_tilemap.flags = @top_tileset.flags
    end
  end
  #--------------------------------------------------------------------------
  # ● フレーム更新
  #--------------------------------------------------------------------------
  alias rk_spriteset_map_update update
  def update
    rk_spriteset_map_update
    rk_update_tileset
    rk_update_tilemap
    rk_update_viewports
  end
  #--------------------------------------------------------------------------
  # ● タイルセットの更新
  #--------------------------------------------------------------------------
  def rk_update_tileset
    @top_tilemap.visible = @top_tileset && RK::LuminousWindow::luminous?
  end
  #--------------------------------------------------------------------------
  # ● タイルマップの更新
  #--------------------------------------------------------------------------
  def rk_update_tilemap
    @top_tilemap.map_data = $game_map.data
    @top_tilemap.ox = $game_map.display_x * 32
    @top_tilemap.oy = $game_map.display_y * 32
    @top_tilemap.update
  end
  #--------------------------------------------------------------------------
  # ● ビューポートの更新
  #--------------------------------------------------------------------------
  def rk_update_viewports
    @viewport_top.ox = $game_map.screen.shake
    @viewport_top.update
  end
  #--------------------------------------------------------------------------
  # ● 解放
  #--------------------------------------------------------------------------
  alias rk_spriteset_map_dispose dispose
  def dispose
    rk_spriteset_map_dispose
    rk_dispose_tilemap
    rk_dispose_viewport
  end
  #--------------------------------------------------------------------------
  # ● タイルマップの解放
  #--------------------------------------------------------------------------
  def rk_dispose_tilemap
    @top_tilemap.dispose
  end
  #--------------------------------------------------------------------------
  # ● ビューポートの解放
  #--------------------------------------------------------------------------
  def rk_dispose_viewport
    @viewport_top.dispose
  end
end